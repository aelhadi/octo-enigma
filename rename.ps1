# Script PowerShell pour renommer les sous-répertoires et remplacer les occurrences dans les fichiers (case-sensitive), en excluant le répertoire Target

# Définir les paramètres
$parentDirectory = "C:\Chemin\Vers\Dossier"
$oldName = "OldName"
$newName = "NewName"
$excludedDirectoryName = "Target"

# Vérifier si le répertoire existe
if (!(Test-Path -Path $parentDirectory)) {
    Write-Error "Le répertoire spécifié n'existe pas."
    exit
}

# Fonction pour remplacer le contenu dans les fichiers (case-sensitive)
function Replace-InFiles($directory, $oldText, $newText, $excludedDir) {
    Get-ChildItem -Path $directory -Recurse -File | Where-Object {
        # Exclure les fichiers dans les répertoires exclus
        -not ($_.FullName -match "\\$excludedDir\\")
    } | ForEach-Object {
        $filePath = $_.FullName
        $fileContent = Get-Content -Path $filePath
        $updatedContent = $fileContent -replace "($oldText)", { 
            param($matches) 
            # Conserver la casse du OldName dans le remplacement
            if ($matches[0] -cmatch "^[A-Z]") {
                return $newText.Substring(0,1).ToUpper() + $newText.Substring(1)
            } else {
                return $newText
            }
        }

        if ($fileContent -ne $updatedContent) {
            Set-Content -Path $filePath -Value $updatedContent
            Write-Host "Remplacement effectué dans le fichier : $filePath"
        }
    }
}

# Fonction pour renommer les répertoires (case-sensitive)
function Rename-SubDirectories($directory, $oldText, $newText, $excludedDir) {
    Get-ChildItem -Path $directory -Recurse -Directory | Where-Object {
        # Exclure les répertoires correspondants à excludedDir
        -not ($_.FullName -match "\\$excludedDir$")
    } | Sort-Object -Property FullName -Descending | ForEach-Object {
        $currentName = $_.Name
        if ($currentName -like "*$oldText*") {
            # Conserver la casse dans le nouveau nom
            $newDirName = $currentName -replace "($oldText)", { 
                param($matches) 
                if ($matches[0] -cmatch "^[A-Z]") {
                    return $newText.Substring(0,1).ToUpper() + $newText.Substring(1)
                } else {
                    return $newText
                }
            }
            $newPath = Join-Path -Path $_.Parent.FullName -ChildPath $newDirName
            Rename-Item -Path $_.FullName -NewName $newPath
            Write-Host "Répertoire renommé : $currentName -> $newDirName"
        }
    }
}

# Appel des fonctions
Write-Host "Remplacement des occurrences dans les fichiers (case-sensitive), en excluant '$excludedDirectoryName'..."
Replace-InFiles -directory $parentDirectory -oldText $oldName -newText $newName -excludedDir $excludedDirectoryName

Write-Host "Renommage des sous-répertoires (case-sensitive), en excluant '$excludedDirectoryName'..."
Rename-SubDirectories -directory $parentDirectory -oldText $oldName -newText $newName -excludedDir $excludedDirectoryName

Write-Host "Opérations terminées avec succès."
