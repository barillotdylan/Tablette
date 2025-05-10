window.addEventListener("DOMContentLoaded", () => {
    const iframe = document.getElementById("iframe");
    const input = document.getElementById("urlInput");
    const closeBtn = document.getElementById("closeBtn");
    const resetBtn = document.getElementById("resetBtn");
    const saveBtn = document.getElementById("saveBtn");
    const errorMessage = document.getElementById("error-message");  // Sélection du message d'erreur

    // Écoute les messages venant du serveur pour ouvrir ou fermer la tablette
    window.addEventListener("message", function(event) {
        if (event.data.action === "open") {
            document.body.style.display = "flex";
            iframe.src = event.data.url || "";
            input.value = event.data.url || "";
            errorMessage.style.display = "none"; // Cache le message d'erreur si la tablette est ouverte
        } else if (event.data.action === "close") {
            document.body.style.display = "none";
            iframe.src = "";
            input.value = "";
            errorMessage.style.display = "none"; // Cache le message d'erreur à la fermeture
        }
    });

    // Bouton pour fermer la tablette
    closeBtn.addEventListener("click", () => {
        fetch("https://tablet/close", { method: "POST" });
    });

    // Bouton pour réinitialiser le lien
    resetBtn.addEventListener("click", () => {
        fetch("https://tablet/resetLink", { method: "POST" });
        iframe.src = "";
        iframe.style.display = "none";  // Cacher l'iframe lors du reset
        input.value = "";
        errorMessage.style.display = "none"; // Cacher le message d'erreur après réinitialisation
    });

    // Vérification et sauvegarde du lien lorsque le bouton "Enregistrer" est cliqué
    saveBtn.addEventListener("click", () => {
        const url = input.value.trim();
        const isValid = /^https:\/\/docs\.google\.com\/(document|spreadsheets)\//.test(url);

        if (isValid) {
            fetch("https://tablet/saveLink", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ url })
            });
            iframe.src = url;
            iframe.style.display = "block"; // Afficher l'iframe lorsque l'URL est valide
            errorMessage.style.display = "none"; // Cacher le message d'erreur si l'URL est valide
        } else {
            iframe.src = "";  // Ne rien charger dans l'iframe
            iframe.style.display = "none";  // Cacher l'iframe
            errorMessage.style.display = "block"; // Afficher le message d'erreur
            input.value = "";  // Réinitialiser le champ de saisie
        }
    });

    // Écouter l'événement Escape pour fermer la tablette
    document.addEventListener("keydown", (event) => {
        if (event.key === "Escape") {
            fetch("https://tablet/close", { method: "POST" });
        }
    });

    // Ferme la tablette si on clique en dehors de la zone
    document.addEventListener("click", (event) => {
        const container = document.querySelector(".container");
        if (!container.contains(event.target)) {
            fetch("https://tablet/close", { method: "POST" });
        }
    });

    // Bloque l'appui sur "Entrée" dans l'input pour vérifier le lien avant de le sauvegarder
    input.addEventListener("keydown", (e) => {
        if (e.key === "Enter") {
            e.preventDefault();
            saveBtn.click();  // Forcer le clic sur le bouton pour effectuer la validation
        }
    });
});
