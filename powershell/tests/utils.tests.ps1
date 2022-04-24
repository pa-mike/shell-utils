BeforeAll { . $PSScriptRoot\..\src\utils.ps1 }
$VerbosePreference = "Continue"
Describe "Timestamp-Echo" {
    BeforeAll {
        $input_string = "Test 1 2 3 4 5"
        $mock_timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
        Mock Get-Date { return $mock_timestamp } # Mock Get-Date so we dont get a race condition
        $example_call_stack = @{ ScriptName = "Example 1"; FunctionName = "Square" }, @{ ScriptName = "Example 2"; FunctionName = "Circle" }
        $example_call_stack_print = "Example 2 ~ Circle"
        Mock Get-PSCallStack { return $example_call_stack }
    }
    Context "Base Call with small call Stack" {
        BeforeAll {
            $result = $(Timestamp-Echo $input_string)6>&1 # Use 6>&1 to redirect Write-Host to our variable for testing
            # Write-Host $
        }
        It "Writes timestamp" {
            [bool]($result -match "$mock_timestamp")  | Should -Be $true
        }
        It "Writes abbreviated call stack" {
            [bool]($result -match "$example_call_stack_print")  | Should -Be $true
        }
        It "Writes input text to shell" {
            [bool]($result -match $input_string)  | Should -Be $true
        } 
    }
    Context "Base Call with 3+ call Stack" {
        BeforeAll {
            $example_call_stack = @{ ScriptName = "Example 1"; FunctionName = "Square" }, @{ ScriptName = "Example 2"; FunctionName = "Circle" }, @{ ScriptName = "Example 3"; FunctionName = "Triangle" }, @{ ScriptName = "Example 4"; FunctionName = "Triangle" }
            $result = $(Timestamp-Echo $input_string)6>&1 # Use 6>&1 to redirect Write-Host to our variable for testing
        }
        It "Writes timestamp" {
            [bool]($result -match "$mock_timestamp")  | Should -Be $true
        }
        It "Writes abbreviated call stack" {
            [bool]($result -match "$example_call_stack_print")  | Should -Be $true
        }
        It "Writes input text to shell" {
            [bool]($result -match $input_string)  | Should -Be $true
        } 
    }
    Context "Without call Stack" {
        BeforeAll {
            $example_call_stack = $null # @{ ScriptName = "Example 1"; FunctionName = "Square" }, @{ ScriptName = "Example 2"; FunctionName = "Circle" }
            Mock Get-PSCallStack { return $example_call_stack }
            $result = $(Timestamp-Echo $input_string)6>&1 # Use 6>&1 to redirect Write-Host to our variable for testing
        }
        It "Writes timestamp" {
            [bool]($result -match "$mock_timestamp")  | Should -Be $true
        }
        It "Writes no call stcak" {
            [bool]($result -match "$example_call_stack_print")  | Should -Be $false # Shitty test TODO
        }
        It "Writes input text to shell" {
            [bool]($result -match $input_string)  | Should -Be $true
        } 
    }
    Context "Function Name contains <ScriptBlock>" {
        BeforeAll {
            $example_call_stack = @{ ScriptName = "Example 1"; FunctionName = "<ScriptBlock>" }, @{ ScriptName = "Example 2"; FunctionName = "<ScriptBlock>" }
            Mock Get-PSCallStack { return $example_call_stack }
            $result = $(Timestamp-Echo $input_string)6>&1 # Use 6>&1 to redirect Write-Host to our variable for testing
        }
        It "Writes timestamp" {
            [bool]($result -match "$mock_timestamp")  | Should -Be $true
        }
        It "Writes no call stcak" {
            [bool]($result -match "$example_call_stack_print")  | Should -Be $false # Shitty test TODO
        }
        It "Writes input text to shell" {
            [bool]($result -match $input_string)  | Should -Be $true
        } 
    }
}
  
Describe "InstallModule-Check" {

    Context "Module Version Supplied" {

        Context "if the module exists" {
            BeforeEach {
                Mock Get-Module { return $true }
                Mock Timestamp-Echo 
                $result = InstallModule-Check Example 1.0.1
            }
            It "it should return Already Installed" {
                $result | Should -Be "Already Installed"
            }
        }
        Context "if the module doesnt exist" { 
            BeforeEach {
                Mock Install-Module { return $true }
                Mock Timestamp-Echo 
                $result = InstallModule-Check Example 1.0.1
            }
            It "it should install it" {
                $result | Should -Be $true
            }
            It "should use Install-Module" {
                Should -Invoke Install-Module -Times 1 -Exactly
            }
        }
    }
    Context "No Module Version" {
        Context "if the module exists" {
            BeforeEach {
                Mock Get-Module { return $true }
                Mock Timestamp-Echo 
                $result = InstallModule-Check Example
            }
            It "it should return Already Installed" {
                $result | Should -Be "Already Installed"
            }
        }
        Context "if the module doesnt exist" { 
            BeforeEach {
                Mock Install-Module { return $true }
                Mock Timestamp-Echo 
                $result = InstallModule-Check Example
            }
            It "it should install it" {
                $result | Should -Be $true
            }
            It "should use Install-Module" {
                Should -Invoke Install-Module -Times 1 -Exactly
            }
        }
    }
}

Describe "Add-LineToProfile" {
    BeforeAll {
        $example_line = "TestLine"
    }
    Context "Profile Contains Line" {
        BeforeEach {
            Mock Timestamp-Echo
            Mock Select-String { return $example_line }
            Mock Add-Content
            # Mock profile { return "example profile" }
            $result = $(Add-LineToProfile $example_line "test_profile_path_string")6>&1 
        }
        It "Should echo line already set" {
            Should -Invoke Timestamp-Echo -Times 1 -Exactly
        }
        It "Shouldn't add a line to profile" {
            Should -Invoke -CommandName Add-Content -Times 0
        }
    }
    Context "Profile does not contain Line" {
        BeforeEach {
            Mock Timestamp-Echo
            Mock Select-String { return $null }
            Mock Add-Content
            # Mock profile { return "example profile" }
            $result = $(Add-LineToProfile $example_line "test_profile_path_string")6>&1 
        }
        It "Should echo line already set" {
            Should -Invoke Timestamp-Echo -Times 1 -Exactly
        }
        It "Shouldn't add a line to profile" {
            Should -Invoke Add-Content -Times 1 -Exactly
        }
    }
}