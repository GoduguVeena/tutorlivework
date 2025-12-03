# PowerShell script to add footer to all standalone pages
$footerCSS = @'

        /* App Footer Styling */
        .app-footer {
            background: rgba(249,250,242,0.95);
            backdrop-filter: blur(12px);
            border-top: 3px solid var(--slate, #CED3DC);
            box-shadow: 0 -8px 32px rgba(39,64,96,0.13);
            padding: 30px 20px;
            margin-top: 50px;
            text-align: center;
            font-family: 'Montserrat', Arial, sans-serif;
            color: #274060;
            position: relative;
            border-radius: 20px 20px 0 0;
        }

        .footer-content {
            max-width: 1200px;
            margin: 0 auto;
        }

        .footer-line {
            margin: 8px 0;
            line-height: 1.6;
        }

        .footer-line.guidance {
            font-size: 1em;
            font-weight: 600;
            color: #274060;
            margin-bottom: 12px;
        }

        .footer-line.team {
            font-size: 0.95em;
            font-weight: 500;
            color: #444;
        }

        .footer-line.copyright {
            font-size: 0.9em;
            font-weight: 600;
            color: #274060;
            margin-top: 15px;
            padding-top: 15px;
            border-top: 2px solid rgba(39,64,96,0.1);
        }

        .footer-highlight {
            color: #FFC857;
            font-weight: 700;
        }

        .footer-name {
            color: #274060;
            font-weight: 600;
        }

        @media (max-width: 768px) {
            .app-footer {
                padding: 20px 15px;
                margin-top: 30px;
            }

            .footer-line.guidance {
                font-size: 0.9em;
            }

            .footer-line.team {
                font-size: 0.85em;
            }

            .footer-line.copyright {
                font-size: 0.8em;
            }
        }
'@

$footerHTML = @'

    <footer class="app-footer">
        <div class="footer-content">
            <div class="footer-line guidance">
                Developed under the guidance of <span class="footer-highlight">Dr. P. Penchala Prasad</span>, Associate Professor, CSE(DS), RGMCET
            </div>
            <div class="footer-line team">
                With team <span class="footer-name">Mr. S. Md. Shahid Afrid (23091A32D4)</span> & <span class="footer-name">Ms. G. Veena (23091A32H9)</span>
            </div>
            <div class="footer-line copyright">
                © All Rights Reserved @2025
            </div>
        </div>
    </footer>
'@

# Get all cshtml files with Layout = null
$files = Get-ChildItem -Path "Views" -Filter "*.cshtml" -Recurse | 
    Where-Object { (Get-Content $_.FullName -Raw) -match "Layout\s*=\s*null" }

Write-Host "Found $($files.Count) files with Layout = null"

$processedCount = 0
$skippedCount = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    
    # Skip if footer already exists
    if ($content -match "app-footer" -or $content -match "Dr\.\s*P\.\s*Penchala Prasad") {
        Write-Host "Skipping $($file.Name) - footer already exists"
        $skippedCount++
        continue
    }
    
    # Check if file has closing </style> tag
    if ($content -match "</style>") {
        # Add CSS before </style>
        $content = $content -replace "</style>", "$footerCSS`n    </style>"
    }
    
    # Check if file has closing </body>
    if ($content -match "</body>") {
        # Add HTML before </body>
        $content = $content -replace "</body>", "$footerHTML`n</body>"
    }
    
    # Save the file
    Set-Content -Path $file.FullName -Value $content -NoNewline
    Write-Host "Processed: $($file.Name)"
    $processedCount++
}

Write-Host "`nSummary:"
Write-Host "Processed: $processedCount files"
Write-Host "Skipped: $skippedCount files"
Write-Host "Total: $($files.Count) files"
