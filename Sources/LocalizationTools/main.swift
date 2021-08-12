/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import ArgumentParser

struct LocalizationTools: ParsableCommand {
    @Option(help: "Path to the project")
    var projectPath: String
    
    @Option(name: .customLong("l10n-project-path"), help: "Path to the l10n project")
    var l10nProjectPath: String
    
    @Flag(name: .customLong("export"), help: "To determine if we should run the export task.")
    var runExportTask = false
    
    @Flag(name: .customLong("import"), help: "To determine if we should run the import task.")
    var runImportTask = false
    
    static var configuration: CommandConfiguration {
        CommandConfiguration(commandName: "l10nTools", abstract: "Scripts for automating l10n for Mozilla iOS projects.", discussion: "", version: "1.0", shouldDisplay: true, subcommands: [], defaultSubcommand: nil, helpNames: .long)
        
    }
    
    private func validateArguments() -> Bool {
        switch (runExportTask, runImportTask) {
        case (false, false):
            print("Please specify which task to run with --export, --import")
            return false
        case (true, true):
            print("Please choose a single task to run")
            return false
        default: return true;
        }
    }
    
    mutating func run() throws {
        guard validateArguments() else { Self.exit() }
        
        let shippingLocales = URL(fileURLWithPath: projectPath).deletingLastPathComponent().appendingPathComponent("shipping_locales.txt")
        let locales = try! String(contentsOf: shippingLocales).components(separatedBy: .newlines).filter { !$0.isEmpty }


        if runImportTask {
            ImportTask(xcodeProjPath: projectPath, l10nRepoPath: l10nProjectPath, locales: locales).run()
        }
        
        if runExportTask {
            ExportTask(xcodeProjPath: projectPath, l10nRepoPath: l10nProjectPath).run()
            CreateTemplatesTask(l10nRepoPath: l10nProjectPath).run()
        }
    }
}

LocalizationTools.main()
