{...}: {
  age.secrets = {
    "factorio.secret.json".file = "./factorio.secret.age";
    "invoiceshelf-env.secret".file = "./invoiceshelf-env.secret.age";
    "servas-env.secret".file = "./server-env.secret.age";
  };
}
