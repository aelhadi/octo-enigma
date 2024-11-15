# Script PowerShell pour renommer les sous-répertoires et remplacer les occurrences dans les fichiers

# Définir les paramètres
$parentDirectory = "C:\Chemin\Vers\Dossier"
$oldName = "OldName"
$newName = "NewName"

# Vérifier si le répertoire existe
if (!(Test-Path -Path $parentDirectory)) {
    Write-Error "Le répertoire spécifié n'existe pas."
    exit
}

# Fonction pour remplacer le contenu dans les fichiers
function Replace-InFiles($directory, $oldText, $newText) {
    Get-ChildItem -Path $directory -Recurse -File | ForEach-Object {
        $fileContent = Get-Content -Path $_.FullName
        $updatedContent = $fileContent -replace $oldText, $newText
        if ($fileContent -ne $updatedContent) {
            Set-Content -Path $_.FullName -Value $updatedContent
            Write-Host "Remplacement effectué dans le fichier : $($_.FullName)"
        }
    }
}

# Fonction pour renommer les répertoires
function Rename-SubDirectories($directory, $oldText, $newText) {
    Get-ChildItem -Path $directory -Recurse -Directory | ForEach-Object {
        if ($_.Name -like "*$oldText*") {
            $newDirName = $_.Name -replace $oldText, $newText
            $newPath = Join-Path -Path $_.Parent.FullName -ChildPath $newDirName
            Rename-Item -Path $_.FullName -NewName $newPath
            Write-Host "Répertoire renommé : $($_.FullName) -> $newPath"
        }
    }
}

# Appel des fonctions
Write-Host "Remplacement des occurrences dans les fichiers..."
Replace-InFiles -directory $parentDirectory -oldText $oldName -newText $newName

Write-Host "Renommage des sous-répertoires..."
Rename-SubDirectories -directory $parentDirectory -oldText $oldName -newText $newName

Write-Host "Opérations terminées avec succès."
