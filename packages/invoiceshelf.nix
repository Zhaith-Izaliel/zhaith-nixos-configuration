{
  stdenv,
  pkgs,
  fetchzip,
  dataDir ? "/var/lib/InvoiceShelf",
}:
stdenv.mkDerivation rec {
  pname = "InvoiceShelf";
  version = "1.1.0";

  src = fetchzip {
    url = "https://invoiceshelf.com/releases/download/${version}.zip";
    hash = "sha256-3taY+JsXivI/zGo9numQno2/iws7pIFkvUZnvg2KZCU=";
    extension = "zip";
    stripRoot = false;
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -ra InvoiceShelf $out

    # symlink mutable data into the nix store due to crater path requirements
    rm -r $out/storage $out/bootstrap/cache
    ln -s ${dataDir}/.env $out/.env
    ln -s ${dataDir}/storage $out/storage
    ln -s ${dataDir}/public/storage $out/public/storage
    ln -s ${dataDir}/bootstrap/cache $out/bootstrap/cache

    runHook postInstall
  '';

  postPatch = ''
    # Change default sqlite database path to absolute path since symlinks are
    # not followed by crater/lavarel
    substituteInPlace InvoiceShelf/app/Http/Controllers/V1/Installation/DatabaseConfigurationController.php \
      --replace-fail "database_path('database.sqlite')" "'${dataDir}/database.sqlite'"

    # substituteInPlace InvoiceShelf/config/filesystems.php \
    #   --replace-fail "storage_path('app')," "'${dataDir}/app'"

    # substituteInPlace InvoiceShelf/config/filesystems.php \
    #   --replace-fail "storage_path('app/public')" "'${dataDir}/app'"

    substituteInPlace InvoiceShelf/config/mail.php \
      --replace-fail "'sendmail' => '/usr/sbin/sendmail -bs'" "'sendmail' => '${pkgs.system-sendmail}/bin/sendmail -bs'"
  '';
}
