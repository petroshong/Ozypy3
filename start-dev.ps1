# PowerShell script to start the frontend development server
# This script handles port conflicts and PowerShell command limitations

# Set the base directory path (project root)
$baseDir = $PSScriptRoot
$frontendDir = Join-Path $baseDir "frontend"
$configFile = Join-Path $frontendDir "env.development"

# Load .env.development file if it exists
$envConfig = @{}
if (Test-Path $configFile) {
    Get-Content $configFile | ForEach-Object {
        if ($_ -match "^\s*([^#][^=]+)=(.*)$") {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            $envConfig[$key] = $value
        }
    }
}

# Function to find a free port starting from the specified port
function Find-FreePort {
    param (
        [int]$StartPort = 3000,
        [int]$MaxPort = 3020
    )
    
    $port = $StartPort
    
    while ($port -le $MaxPort) {
        $testConnection = Test-NetConnection -ComputerName localhost -Port $port -InformationLevel Quiet -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        
        if (-not $testConnection) {
            return $port  # Port is free
        }
        
        Write-Host "Port $port is in use, trying port $($port + 1)..."
        $port++
    }
    
    Write-Warning "Could not find a free port between $StartPort and $MaxPort"
    return $StartPort  # Return original port if no free ports found
}

# Get configured port or default to 3000
$configuredPort = if ($envConfig.ContainsKey("PORT")) { [int]$envConfig["PORT"] } else { 3000 }
Write-Host "Configured port: $configuredPort"

# Find a free port starting from the configured port
$freePort = Find-FreePort -StartPort $configuredPort -MaxPort ($configuredPort + 20)

if ($freePort -ne $configuredPort) {
    Write-Host "Port $configuredPort is in use, using port $freePort instead."
    
    # Ask if the user wants to update the env.development file
    $updateEnvFile = Read-Host "Do you want to update env.development with the new port? (y/n)"
    
    if ($updateEnvFile -eq "y" -or $updateEnvFile -eq "Y") {
        if (Test-Path $configFile) {
            $content = Get-Content $configFile
            $updated = $false
            
            $newContent = $content | ForEach-Object {
                if ($_ -match "^\s*PORT=") {
                    $updated = $true
                    "PORT=$freePort"
                } else {
                    $_
                }
            }
            
            if (-not $updated) {
                $newContent += "PORT=$freePort"
            }
            
            $newContent | Set-Content $configFile
            Write-Host "Updated env.development with PORT=$freePort"
        } else {
            "PORT=$freePort" | Set-Content $configFile
            Write-Host "Created env.development with PORT=$freePort"
        }
    }
}

# Set the environment variable for the port
$env:PORT = $freePort

# Navigate to the frontend directory
Set-Location $frontendDir

# Check for running processes on the port and offer to kill them
$runningProcesses = Get-NetTCPConnection -LocalPort $freePort -ErrorAction SilentlyContinue | 
                   Select-Object -ExpandProperty OwningProcess | 
                   ForEach-Object { Get-Process -Id $_ -ErrorAction SilentlyContinue } | 
                   Select-Object Id, ProcessName

if ($runningProcesses) {
    Write-Host "Found these processes running on port $freePort:" -ForegroundColor Yellow
    $runningProcesses | Format-Table -AutoSize
    
    $killProcesses = Read-Host "Do you want to kill these processes? (y/n)"
    
    if ($killProcesses -eq "y" -or $killProcesses -eq "Y") {
        foreach ($process in $runningProcesses) {
            try {
                Stop-Process -Id $process.Id -Force
                Write-Host "Killed process $($process.ProcessName) (PID: $($process.Id))" -ForegroundColor Green
            } catch {
                Write-Error "Failed to kill process $($process.ProcessName) (PID: $($process.Id)): $_"
            }
        }
    } else {
        Write-Host "Attempting to use port $freePort anyway..." -ForegroundColor Yellow
    }
}

# Use either pnpm or npm based on what's available
$usePnpm = Get-Command pnpm -ErrorAction SilentlyContinue
if ($usePnpm) {
    # Run the development server with pnpm
    Write-Host "Starting development server on port $freePort with pnpm..."
    pnpm run dev
} else {
    # Run the development server with npm
    Write-Host "Starting development server on port $freePort with npm..."
    npm run dev
} 