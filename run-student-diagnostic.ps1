# Quick diagnostic for student 23091A32D4
# This will show EXACTLY what's in the database for this student

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STUDENT 23091A32D4 DIAGNOSTIC" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$connectionString = "Server=(localdb)\mssqllocaldb;Database=TutorLiveMentorDb;Trusted_Connection=True;MultipleActiveResultSets=true"

try {
    # Read and execute the SQL script
    $sqlScript = Get-Content "diagnose-student-23091a32d4.sql" -Raw
    
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    $connection.Open()
    
    Write-Host "Connected to database" -ForegroundColor Green
    Write-Host ""
    
    # Execute the script
    $command = $connection.CreateCommand()
    $command.CommandText = $sqlScript
    
    # Use ExecuteReader to handle multiple result sets
    $reader = $command.ExecuteReader()
    
    do {
        if ($reader.HasRows) {
            # Get column names
            $columns = @()
            for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                $columns += $reader.GetName($i)
            }
            
            # Print header
            Write-Host ($columns -join " | ") -ForegroundColor Yellow
            Write-Host ("-" * 80) -ForegroundColor Gray
            
            # Print rows
            while ($reader.Read()) {
                $row = @()
                for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                    $value = $reader.GetValue($i)
                    if ($value -is [DBNull]) {
                        $row += "NULL"
                    } else {
                        $row += $value.ToString()
                    }
                }
                Write-Host ($row -join " | ") -ForegroundColor White
            }
            Write-Host ""
        }
    } while ($reader.NextResult())
    
    $reader.Close()
    $connection.Close()
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "DIAGNOSTIC COMPLETE" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Stack Trace:" -ForegroundColor Yellow
    Write-Host $_.Exception.StackTrace -ForegroundColor Gray
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
