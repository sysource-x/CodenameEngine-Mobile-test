package funkin.options.categories;

class MiscOptions extends OptionsScreen {
    public override function new() {
        super("Miscellaneous", "Use this menu to reset save data or engine settings.", null, #if UPDATE_CHECKING 'UP_DOWN' #else 'NONE' #end, 'A_B');

        #if UPDATE_CHECKING
        add(new Checkbox(
            "Enable Nightly Updates",
            "If checked, will also include nightly builds in the update checking.",
            "betaUpdates"));

        add(new TextOption(
            "Check for Updates",
            "Select this option to check for new engine updates.",
            function() {
                // Verificar atualizações apenas se permitido
                #if !mobile
                var report = funkin.backend.system.updating.UpdateUtil.checkForUpdates();
                if (report.newUpdate) {
                    FlxG.switchState(new funkin.backend.system.updating.UpdateAvailableScreen(report));
                } else {
                    // Carregar som de cancelamento do diretório interno
                    CoolUtil.playMenuSFX("assets/sounds/menu/cancel.ogg");
                    updateDescText("No update found.");
                }
                #else
                CoolUtil.playMenuSFX("assets/sounds/menu/cancel.ogg");
                updateDescText("Update checking is not available on mobile.");
                #end
            }));
        #end

        add(new TextOption(
            "Reset Save Data",
            "Select this option to reset save data. This will remove all of your highscores.",
            function() {
                // Resetar os dados salvos
                FlxG.save.data = {};
                FlxG.save.flush();
                //CoolUtil.playMenuSFX("assets/sounds/menu/reset.ogg");
                updateDescText("Save data has been reset.");
            }));

        add(new TextOption(
            "Restore Default Settings",
            "Select this option to restore all settings to their default values.",
            function() {
                // Restaurar configurações padrão
                Options.loadDefaultSettings();
                //CoolUtil.playMenuSFX("assets/sounds/menu/reset.ogg");
                updateDescText("Settings have been restored to default.");
            }));
    }
}
