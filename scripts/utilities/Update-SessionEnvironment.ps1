﻿# Copyright © 2017 - 2021 Chocolatey Software, Inc.
# Copyright © 2015 - 2017 RealDimensions Software, LLC
# Copyright © 2011 - 2015 RealDimensions Software, LLC & original authors/contributors from https://github.com/chocolatey/chocolatey
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function Update-SessionEnvironment {
<#
.SYNOPSIS
Updates the environment variables of the current powershell session with
any environment variable changes that may have occured during a
Chocolatey package install.

.DESCRIPTION
When Chocolatey installs a package, the package author may add or change
certain environment variables that will affect how the application runs
or how it is accessed. Often, these changes are not visible to the
current PowerShell session. This means the user needs to open a new
PowerShell session before these settings take effect which can render
the installed application nonfunctional until that time.

Use the Update-SessionEnvironment command to refresh the current
PowerShell session with all environment settings possibly performed by
Chocolatey package installs.

.NOTES
This method is also added to the user's PowerShell profile as
`refreshenv`. When called as `refreshenv`, the method will provide
additional output.

Preserves `PSModulePath` as set by the process starting in 0.9.10.

.INPUTS
None

.OUTPUTS
None
#>

  $userName = $env:USERNAME
  $architecture = $env:PROCESSOR_ARCHITECTURE
  $psModulePath = $env:PSModulePath

  #ordering is important here, $user should override $machine...
  $ScopeList = 'Process', 'Machine'
  if ($userName -notin 'SYSTEM', "${env:COMPUTERNAME}`$") {
    # but only if not running as the SYSTEM/machine in which case user can be ignored.
    $ScopeList += 'User'
  }
    foreach ($Scope in $ScopeList) {
        [Environment]::GetEnvironmentVariables($Scope) |
            ForEach-Object {
                $key = $_.Key
                $value = $_.Value
                if ($null -ne $key -and $null -ne $value) {
                    Set-Item "Env:$_" -Value (Get-EnvironmentVariable -Scope $Scope -Name $_)
                }
            }
    }

  #Path gets special treatment b/c it munges the two together
  $paths = 'Machine', 'User' |
    ForEach-Object {
            [Environment]::GetEnvironmentVariable('PATH', $_) -split ';'
    } |
    Select-Object -Unique
  $Env:PATH = $paths -join ';'

  # PSModulePath is almost always updated by process, so we want to preserve it.
  $env:PSModulePath = $psModulePath

    # Restore session variables
    if ($userName) { $env:USERNAME = $userName }
    if ($architecture) { $env:PROCESSOR_ARCHITECTURE = $architecture }
    if ($psModulePath) { $env:PSModulePath = $psModulePath }

    Write-Host "Environment variables refreshed for current session." -ForegroundColor Green
}

Set-Alias refreshenv Update-SessionEnvironment