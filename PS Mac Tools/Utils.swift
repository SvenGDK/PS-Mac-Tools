//
//  Utils.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 06/01/2024.
//

import Foundation

class Utils {
    
    public var Arch: String?
    
    func CPUType() -> Int {
        var cputype = UInt32(0)
        var size = cputype.bitWidth
        let result = sysctlbyname("hw.cputype", &cputype, &size, nil, 0)
        if result == -1 {
            if errno == ENOENT {
                return 0
            }
            return -1
        }
        return Int(cputype)
    }

    let CPU_ARCH_MASK = 0xff // Mask for architecture bits
    let CPU_TYPE_X86 = cpu_type_t(7)
    let CPU_TYPE_ARM = cpu_type_t(12)

    public func CPUTypeString() {
        let type: Int = CPUType()
        let cpu_arch = type & CPU_ARCH_MASK
        if cpu_arch == CPU_TYPE_X86 {
            Arch = "x86"
        }
        if cpu_arch == CPU_TYPE_ARM {
            Arch = "arm64"
        }
    }
    
}
