package test

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go-v2/service/ec2"
	aws "github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/git"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

func Teardown(t *testing.T, category string, directory string, keyPair *aws.Ec2Keypair, agent *ssh.SSHAgent, id string, terraformOptions *terraform.Options) {

	_, err := terraform.DestroyContextE(t, t.Context(), terraformOptions)
	if err != nil {
		if strings.Contains(err.Error(), "operation error EC2: DisassociateAddress") {
			t.Logf("Ignored error while destroying cluster: %s", err)
		}
		t.Fatalf("Error destroying cluster: %s", err)
	}

	gwd := git.GetRepoRootContext(t, t.Context(), "") // git working directory
	fwd, err4 := filepath.Abs(gwd)                    // full working directory
	if err4 != nil {
		require.NoError(t, err4)
	}
	testDataDir := filepath.Join(fwd, "test", "data", id)
	err5 := os.RemoveAll(testDataDir)
	require.NoError(t, err5)
	exampleDataDir := filepath.Join(fwd, "examples", category, directory, "data")
	err6 := os.RemoveAll(exampleDataDir)
	require.NoError(t, err6)
	aws.DeleteEC2KeyPairContext(t, t.Context(), keyPair)
	agent.Stop()
}

func Setup(t *testing.T, category string, directory string, region string, owner string, uniqueID string) (*terraform.Options, *aws.Ec2Keypair) {
	// Create an EC2 KeyPair that we can use for SSH access
	keyPairName := fmt.Sprintf("tf-%s-%s-%s", category, directory, uniqueID)
	keyPair := aws.CreateAndImportEC2KeyPairContext(t, t.Context(), region, keyPairName)

	// tag the key pair so we can find in the access module
	client, err := aws.NewEc2ClientContextE(t, t.Context(), region)
	if err != nil {
		t.Fatalf("Error creating EC2 client: %s", err)
	}

	input := &ec2.DescribeKeyPairsInput{
		KeyNames: []string{keyPairName},
	}
	result, err := client.DescribeKeyPairs(t.Context(), input)
	if err != nil {
		t.Fatalf("Error describing key pair: %s", err)
	}
	if len(result.KeyPairs) == 0 {
		t.Fatalf("No key pair found with name: %s", keyPairName)
	}
	if result.KeyPairs[0].KeyPairId == nil {
		t.Fatalf("KeyPairId is nil for key pair: %s", keyPairName)
	}

	aws.AddTagsToResourceContext(t, t.Context(), region, *result.KeyPairs[0].KeyPairId, map[string]string{"Name": keyPairName, "Owner": owner})

	retryableTerraformErrors := map[string]string{
		// The reason is unknown, but eventually these succeed after a few retries.
		".*unable to verify signature.*":               "Failed due to transient network error.",
		".*unable to verify checksum.*":                "Failed due to transient network error.",
		".*no provider exists with the given name.*":   "Failed due to transient network error.",
		".*registry service is unreachable.*":          "Failed due to transient network error.",
		".*connection reset by peer.*":                 "Failed due to transient network error.",
		".*TLS handshake timeout.*":                    "Failed due to transient network error.",
		".*operation error EC2: DisassociateAddress.*": "Failed due to transient AWS reconcile error.",
	}
	gwd := git.GetRepoRootContext(t, t.Context(), "") // git root dir
	fgd, err := filepath.Abs(gwd)                     // full git root dir
	if err != nil {
		t.Fatalf("Error getting absolute path of git root directory: %s", err)
	}
	testDataDir := filepath.Join(fgd, "test", "data", uniqueID)
	testPluginDataDir := filepath.Join(testDataDir, "tf_plugin_cache")

	if err := os.MkdirAll(testDataDir, 0755); err != nil {
		t.Fatalf("Error creating test data directory: %s", err)
	}
	if err := os.MkdirAll(testPluginDataDir, 0755); err != nil {
		t.Fatalf("Error creating test plugin cache directory: %s", err)
	}

	exampleDir := filepath.Join(fgd, "examples", category, directory)
	if err := os.CopyFS(testDataDir, os.DirFS(exampleDir)); err != nil {
		t.Fatalf("Error copying example files: %s", err)
	}

	if globalCache := os.Getenv("GLOBAL_TF_PLUGIN_CACHE"); globalCache != "" {
		if err := os.CopyFS(testPluginDataDir, os.DirFS(globalCache)); err != nil {
			t.Logf("Warning: failed to copy global plugin cache: %s", err)
		}
	}

	// Remove hidden files/directories (like .terraform) to prevent local state collisions
	entries, err := os.ReadDir(testDataDir)
	if err == nil {
		for _, entry := range entries {
			if strings.HasPrefix(entry.Name(), ".") {
				if err := os.RemoveAll(filepath.Join(testDataDir, entry.Name())); err != nil {
					t.Logf("Warning: failed to remove hidden file %s: %s", entry.Name(), err)
				}
			}
		}
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// example files are copied to the test directory
		TerraformDir: testDataDir,
		// Variables to pass to our Terraform code using -var options
		Vars: map[string]any{
			"key":        keyPair.PublicKey,
			"key_name":   keyPairName,
			"identifier": uniqueID,
		},
		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION":  region,
			"TF_IN_AUTOMATION":    "1",
			"TF_PLUGIN_CACHE_DIR": testPluginDataDir,
		},
		NoColor:                  true,
		RetryableTerraformErrors: retryableTerraformErrors,
	})
	return terraformOptions, keyPair
}
