//
//  StorageManager.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-01-14.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import Foundation

public final class StorageManager {
    
    public static let shared: StorageManager = StorageManager()
    
    private let baseDirectoryUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    private lazy var projectsDirectoryUrl: URL = {
        return baseDirectoryUrl.appendingPathComponent("projects")
    }()
    
    private lazy var projectsExportDirectoryUrl: URL = {
        return baseDirectoryUrl.appendingPathComponent("export")
    }()
    
    public func directoryForProject(with id: String) -> URL {
        return projectsDirectoryUrl.appendingPathComponent(id)
    }
    
    public func directoryForProjectExport(with id: String) -> URL {
        var isDir: ObjCBool = false
        if !FileManager.default.fileExists(atPath: projectsExportDirectoryUrl.path, isDirectory: &isDir) {
            do {
                try FileManager.default.createDirectory(at: projectsExportDirectoryUrl, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed Creating Project Export Directory")
            }
        }
        
        return projectsExportDirectoryUrl
    }
    
    public func archiveUrl(for project: Project) -> URL {
        return directoryForProjectExport(with: project.id).appendingPathComponent("\(project.id).zip")
    }
    
    public func metadataUrl(for project: Project) -> URL {
        return metadataUrlForProject(with: project.id)
    }
    
    public func metadataUrlForProject(with id: String) -> URL {
        return directoryForProject(with: id).appendingPathComponent("metadata.json")
    }
    
    public func store(project: Project) -> Bool {
        do {
            let data = try JSONEncoder().encode(project)
            return FileManager.default.createFile(atPath: metadataUrl(for: project).path, contents: data, attributes: nil)
        } catch (let error) {
            print("Project Encode Failed. Not Storing. Error: \(error)")
            return false
        }
    }
    
    public func delete(project: Project) -> Bool {
        let zipUrl = archiveUrl(for: project)
        let sessionUrl = directoryForProject(with: project.id)
        
        do {
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: zipUrl.path, isDirectory: &isDir) {
                try FileManager.default.removeItem(at: zipUrl)
            }
            
            if FileManager.default.fileExists(atPath: sessionUrl.path, isDirectory: &isDir) {
                try FileManager.default.removeItem(at: sessionUrl)
            }
            return true
        } catch {
            return false
        }
    }
    
    public func loadProject(with id: String) -> Project? {
        guard let data = FileManager.default.contents(atPath: metadataUrlForProject(with: id).path) else {
            print("Project Data Not Found.")
            return nil
        }
        
        guard let project = try? JSONDecoder().decode(Project.self, from: data) else {
            print("Project Decode Failed.")
            return nil
        }

        return project
    }
    
    public func fetchAllProjects() -> [Project] {
        guard let listing = try? FileManager.default.contentsOfDirectory(atPath: projectsDirectoryUrl.path) else { return [] }
        
        let projects = listing.map { folderName -> Project? in
            return loadProject(with: folderName)
        }
        .compactMap { $0 }
        
        return projects
    }
}
