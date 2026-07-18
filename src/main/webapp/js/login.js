    const roleInput = document.getElementById("role");
    const roleButtons = document.querySelectorAll(".role-btn");

    roleButtons.forEach(button => {

    button.addEventListener("click", function () {

        roleButtons.forEach(btn => {

            btn.classList.remove(
                "bg-emerald-500",
                "text-white",
                "font-semibold"
            );

            btn.classList.add("text-slate-600");

        });

        this.classList.remove("text-slate-600");

        this.classList.add(
            "bg-emerald-500",
            "text-white",
            "font-semibold"
        );

        roleInput.value = this.dataset.role;

    });

});

    function showPassword() {

    const password = document.getElementById("password");

    const slash = document.getElementById("slash");

    if(password.type==="password"){

    password.type="text";

    slash.style.display="none";

}else{

    password.type="password";

    slash.style.display="block";

}

}
