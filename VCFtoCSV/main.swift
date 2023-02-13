//
//  main.swift
//  VCFtoCSV
//
//  Created by Kastro on 12/2/23.
//

import Foundation

let arguments = CommandLine.arguments

guard arguments.count == 2 else {
    print("Usage: \(arguments[0]) INPUT_VCF_FILE")
    exit(1)
}

let vcfFile = arguments[1]

let fileManager = FileManager.default

if !fileManager.fileExists(atPath: vcfFile) {
    print("File not found: \(vcfFile)")
    exit(1)
}

// get folder path of vcf file using URL
let vcfURL = URL(fileURLWithPath: vcfFile)
let vcfFolder = vcfURL.deletingLastPathComponent().path

// get file name of vcf file
let vcfFileName = vcfURL.lastPathComponent

// get file name without extension
let vcfFileNameWithoutExtension = vcfFileName.components(separatedBy: ".")[0]

// create csv file path
let csvFileName = "\(vcfFileNameWithoutExtension).csv"

let csvFile = "\(vcfFolder)/\(csvFileName)"

convertVCFtoCSV(vcfFile: vcfFile, csvFile: csvFile)

// Function to convert vcf file to csv
func convertVCFtoCSV(vcfFile: String, csvFile: String) {
    let vcfData = try? String(contentsOfFile: vcfFile, encoding: .utf8)
    let vcfLines = vcfData!.components(separatedBy: .newlines)
    var csvData = "Name,Phones\n"
    
    let phonePattern = "item\\d+\\.TEL(:|;)"
    let specialPhonesRegex = try? NSRegularExpression(pattern: phonePattern, options: [])
    
    var name = ""
    var phones = [String]()
    
    for line in vcfLines {
        if line.hasPrefix("FN") {
            name = line.components(separatedBy: ":")[1]
            print("name: \(name)")
        }
        
        let specialPhoneMatches = specialPhonesRegex?.matches(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count))
        
        if line.hasPrefix("TEL") || specialPhoneMatches?.count ?? 0 > 0 {
            let phoneNumber = line.components(separatedBy: ":")[1]
            print("phone: \(phoneNumber)")
            phones.append(phoneNumber)
            
        }
        
        if line == "END:VCARD" {
            if name != "" && phones.count > 0 {
                let phoneList = phones.joined(separator: ",")
                csvData += "\(name),\(phoneList)\n"
            }
            
            name = ""
            phones.removeAll()
        }
    }
    
    try? csvData.write(toFile: csvFile, atomically: true, encoding: .utf8)
}

