# Version 0.7
# ArmDataPath support fliegt raus, da es nur Probleme bereitet und eh nicht
# als Hardwaresynthese benutzt werden kann
# Genau genommen gibt es Probleme bei ArmCore
###############################################################
# Ewartungen vom Programm:
# - Die Kommentare von ARM_SIM_LIB und use.ARM... wurden NICHT
#   aus den Obermodulen entfernt -> Falls doch muesst ihr diese
#   Bloecke einfach wieder reinkopieren, stelle ist relativ egal,
#   solange library ARM_SIM_LIB; ueber den use.ARM_SIM_LIB steht
# - Die Dateien wurden NICHT unbenannt -> Diese MUESSEN GENAUSO
#   wie die Vorgaben heissen!
# Stabilitaet vom Programm:
# - Diese Kommentare duerfen aber anders eingerueckt worden sein
#   diese werden sehr flexibel mit Regex gesucht (gross/klein-
#   schreibung ist zB egal). Falls nach diesen Kommentaren etwas
#   hinzugefuegt wurde, muss dieses auskommentiert sein:
#   -- use ARM_SIM_LIB.ArmRegisterBitAdder;
#     --      use ARM_SIM_LIB.armREGISTERBITADDER; --Modul vllt fehlerhaft
#   sind erlaubt, aber:
#   -- use ARM_SIM_LIB.ArmRegisterBitAdder; Modul vllt fehlerhaft
#  ist NICHT erlaubt, da quasi "nur" der Teil bis ARM_SIM_LIB
#  ersetzt wird.
# Da hinten also nachher "Modul vllt fehlerhaft" steht ohne
#   auskommentiert worden zu sein, wird die zu einem Fehler fuehren
# - Ansonsten sollte das Programm sehr stabil laufen
#   Es darf ohne weiteres alles mehrmals ausgefuehrt werden
#   und es sollte sich nach dem ersten ausfuehren nichts aendern
# - Vor der Simulation sollten ja alle ARM_SIM_LIBS auskommentiert
#   werden und dies kann man einfach machen, indem man alle seine
#   Module wieder mit denen von ASL tauscht
# - Fuer den Sonderfall falls man ArmArithInstructionCtrl
#   von ASL nutzen muss, wird eine Subroutine aufgerufen,
#   welche in allen VHDL Dateien ganz oben library ARM_SIM_LIB;
#   hinzufuegt und aus use work.ArmTypes.all;
#   -> use ARM_SIM_LIB.ArmTypes.all; macht
#   Eine doppelte Initialiserung von ASL ist nicht verboten
#   Nutzt man wieder die eigene, so werden alle Aenderungen
#   wieder rueckgangig gemacht und die erste Zeile mit
#   ARM_SIM_LIB entfernt
#   Auch diese Subroutine sollte sehr robust sein und
#   das ersetzen von ArmArithInstructionCtrl kann auch
#   mehrmals hintereinander ausgefuehrt werden, ohne Probleme
#   zu verursachen
# Fehler die durch eine alte Kodierung von Dateien hervorgerufen
# werden koennten, sollten auch abgefangen werden, falls jmd also
# noch Latin-1 benutzt, so sollte sich das Programm genauso verhalten
# wie bei einer "richtigen" Kodierung mit UTF-8 -> Das war ein
# gravierende Schwaeche bei den ersten Versionen dieses Skripts
# Hier besteht also noch die groesste Wahrscheinlichkeit auf einen
# Fehler zu stossen!
###############################################################

import os
# Es wird am Ende immer \n geschrieben, auch auf Windows, denn laut
# python 3 library https://docs.python.org/3/library/os.html
# os.linesep:
# Do not use os.linesep as a line terminator when writing files opened
# in text mode (the default); use a single '\n' instead, on all platforms.
import re
import glob
import sys
# os.rename() funktioniert unter Win nicht, falls Datei
# schon vorhanden ist -> shutil.move() loest dieses Problem
import shutil
from easygui import *
# import fileinput - Hat bei unterschiedlichen codecs versagt
# Interessanter Bug unter Windows, stellt man als encoding UTF-8
# explizit ein, so kodiert er Umlaute um in Sonderzeichen,
# obwohl das Ursprungsdokument auch UTF 8 ist. Ohne Angabe von
# Kodierung scheint dieser Fehler nicht aufzutreten

title = 'SwitchModules'
filetype = './*.vhd'
allvhdlfiles = []
choices = ['Yes', 'No, do the opposite', 'No, prepare for synthesis']
how_to_use = ('Spacebar can be used to select Modules.\n'
              'Arrowkeys can be used to navigate\n'
              'And Enter triggers OK\n')
used_str = 'These modules are currently USED from ARM_SIM_LIB:\n\n'
#############################################################################
# Initializing Strings and Patterns (Regex Objects)
# asl = ARM_SIM_LIB pattern -> c = commented

use_work_str = '^(\s)*use work.'
use_asl_str = '^(\s)*use ARM_SIM_LIB.'
c_use_work_str = '^(\s)*[-]{2,}(\s)*(use work.)'
c_use_asl_str = '^(\s)*[-]{2,}(\s)*(use ARM_SIM_LIB.)'

use_psr_str = 'use ARM_SIM_LIB.ArmProgramStatusRegister'
program_status_reg = '^(\s)*' + use_psr_str
c_psr = '^(\s)*[-]{2,}(\s)*' + use_psr_str

use_word_man_str = 'use ARM_SIM_LIB.ArmWordManipulation'
word_manipulation = '^(\s)*' + use_word_man_str
c_word_man = '^(\s)*[-]{2,}(\s)*' + use_word_man_str

work_meminterface_pattern = re.compile('entity work.ArmMemInterface', re.I)
asl_meminterface_pattern = re.compile('entity ARM_SIM_LIB.ArmMemInterface',
                                      re.I)
psr_pattern = re.compile(program_status_reg, re.I)
word_man_pattern = re.compile(word_manipulation, re.I)

use_asl_pattern = re.compile(use_asl_str, re.I)
asl_pattern = re.compile('^(\s)*(library ARM_SIM_LIB)(\s)*(;)', re.I)
work_arm_types_pattern = re.compile('^(\s)*(use work.ArmTypes)', re.I)
asl_arm_types_pattern = re.compile('(\s)*(use ARM_SIM_LIB.ArmTypes)', re.I)
c_asl_pattern = re.compile('^(\s)*[-]{2,}(\s)*(library ARM_SIM_LIB)(\s)*(;)',
                           re.I)
#############################################################################


#############################################################################
# Initializing all changable Modules with the name being their fathermodule
# Als Klasse waere das vllt schoener
# Canceled support for ArmRegAddressTranslation, see main for explanaition.
# armControlPath = ['ArmRegAddressTranslation', 'ArmRegisterBitAdder',
armControlPath = ['ArmRegisterBitAdder',
                  'ArmLdmStmNextAddress', 'ArmCoarseInstructionDecoder',
                  'ArmBypassCtrl', 'ArmArithInstructionCtrl']

armDataPath = ['ArmProgramStatusRegister', 'ArmWordManipulation',
               'ArmInstructionAddressRegister',
               'ArmDataReplication', 'ArmRegfile', 'ArmShifter',
               'ArmALU', 'ArmMultiplier']

armTop = ['ArmRS232Interface', 'ArmMemInterface']
# armCore_tb = ['ArmGlobalProbes']
# Fuer das erste Aufgabenblatt nutze armUncoreTop
# armUncoreTop = ['ArmRS232Interface', 'ArmMemInterface']
fathermodules = ['ArmControlPath.vhd',
                 'ArmDataPath.vhd', 'ArmTop.vhd']
moduleEdit = []
moduleEdit.extend(armControlPath)
moduleEdit.extend(armDataPath)
moduleEdit.extend(armTop)
# Fuer das erste Aufgabenblatt
# moduleEdit.extend(armUncoreTop)
#############################################################################


def list_used_asl_files():
    asl_files = []
    for module in fathermodules:
        try:
            input_file = open(module, 'r', errors='surrogateescape')
        except (OSError, IOError):
            print(module + ' not found!\n')
            continue
        for line in input_file:
            if use_asl_pattern.search(line):
                # Falls es asl_arm_types ist ueberspringe
                if asl_arm_types_pattern.search(line):
                    continue
                used_module = re.search(use_asl_str + '(.*);', line,
                                        flags=re.I)
                asl_files.append(used_module.group(2))
    return asl_files


def modify_first_line(line, switch_to_asl):
    found_asl_pattern = asl_pattern.search(line)
    found_c_asl_pattern = c_asl_pattern.search(line)
    if switch_to_asl == 'Yes':
        if not (found_asl_pattern or found_c_asl_pattern):
            line = 'library ARM_SIM_LIB;\n' + line
    else:
        if found_asl_pattern or found_c_asl_pattern:
            line = ''
    return line


def replace_all_arm_types(switch_to_asl):
    # TODO: Change to List
    for filename in glob.iglob(filetype):
        # Slicing the ./ infront of filename
        allvhdlfiles.append(filename[2:])
    for file in allvhdlfiles:
        # There has to be a better way to call the function modify_first_l
        output_str = (file + '.rat')
        #####################################################################
        first = True
        input_file = open(file, 'r', errors='surrogateescape')
        output_file = open(output_str, 'w',
                           errors='surrogateescape')
        for line in input_file:
            if first:
                line = modify_first_line(line, switch_to_asl)
                first = False
            if switch_to_asl == 'Yes':
                line = re.sub(work_arm_types_pattern,
                              '\tuse ARM_SIM_LIB.ArmTypes', line)
            else:
                line = re.sub(asl_arm_types_pattern,
                              '\tuse work.ArmTypes', line)
            output_file.write(line)
        input_file.close()
        output_file.close()
        comment_floating_asl(output_str)
        shutil.move(output_str, file)


def father_module(module):
    if module in armControlPath:
        print('father of ' + module + ' is ControlPath')
        return 'ArmControlPath.vhd'
    if module in armDataPath:
        print('father of ' + module + ' is DataPath')
        return 'ArmDataPath.vhd'
    if module in armTop:
        print('father of ' + module + ' is ArmTop')
        return 'ArmTop.vhd'
    # if module in armCore_tb:
    #     print('father of ' + module + ' is ArmCore_tb')
    #     return 'ArmCore_tb.vhd'
    return None


def backup():
    overwrittenmsg = ('Should ALL files be overwritten? (Yes)\n'
                      '    Or should the backup stop? (No)')
    overwriteall = False
    if boolbox('Should all files be backed up?', title=title):
        try:
            os.mkdir('./_backup_')
        except(OSError):
            print('backup Folder already exists')
        for filename in glob.iglob(filetype):
            print(filename)
            if (os.path.exists(os.getcwd() + '/_backup_/' + filename)
                    and not overwriteall):
                if not boolbox(overwrittenmsg, title=title):
                    break
                else:
                    overwriteall = True
            shutil.copy(filename, os.getcwd() + '/_backup_/' + filename)
        return True


def comment_floating_asl(file):
    input_file = open(file, 'r', errors='surrogateescape')
    output_file = open(file + '.cfa', 'w',
                       errors='surrogateescape')
    comment_asl = True
    for line in input_file:
        if use_asl_pattern.search(line):
            comment_asl = False
    # To reopen file
    input_file.close()
    reopen_input = open(file, 'r', errors='surrogateescape')
    for line in reopen_input:
        if comment_asl:
            line = re.sub(asl_pattern, '--library ARM_SIM_LIB;',
                          line)
        output_file.write(line)
    reopen_input.close()
    output_file.close()
    shutil.move(file + '.cfa', file)
    return None


def switch_library(module, switch_to_asl, modified_fatherfile=None):
    if modified_fatherfile:
        fatherfile = modified_fatherfile
    else:
        fatherfile = father_module(module)
    input_file = open(fatherfile, 'r', errors='surrogateescape')
    output_file = open(fatherfile + '.tmp', 'w',
                       errors='surrogateescape')
    for line in input_file:
        if switch_to_asl == 'Yes':
            line = re.sub(c_asl_pattern, 'library ARM_SIM_LIB;',
                          line)
            line = re.sub(c_use_asl_str + module, '\tuse ARM_SIM_LIB.'
                          + module, line, flags=re.I)
            if module == 'ArmMemInterface':
                line = re.sub(work_meminterface_pattern,
                              'entity ARM_SIM_LIB.ArmMemInterface', line)
            # Folgende Zeile wird eigentlich nur fuer
            # ArmRegAddressTranslation gebraucht
            # Oder aber wenn Studenten use work.NAME;
            # hinzugefuegt haben, obwohl es nicht noetig war.
            line = re.sub(use_work_str + module, '--\tuse work.'
                          + module, line, flags=re.I)
            output_file.write(line)
        else:
            if module == 'ArmMemInterface':
                line = re.sub(asl_meminterface_pattern,
                              'entity work.ArmMemInterface', line)
            if psr_pattern.search(line) or word_man_pattern.search(line):
                pass
            else:
                line = re.sub(use_asl_str + module, '--\tuse ARM_SIM_LIB.'
                              + module, line, flags=re.I)
            if switch_to_asl == 'No, prepare for synthesis':
                line = re.sub(use_asl_str + module, '--\tuse ARM_SIM_LIB.'
                              + module, line, flags=re.I)
            else:
                # Folgende Zeile wird eigentlich nur fuer
                # ArmRegAddressTranslation gebraucht
                # Fuegt aber work.ArmRS232Interface; und
                # work.ArmMemInterface; ein, obwohl das ein Sonderfall
                # ist laut ArmTop -> SOLLLTE KEIN Unterschied machen
                line = re.sub(c_use_work_str + module, '\tuse work.'
                              + module, line, flags=re.I)
            output_file.write(line)
    input_file.close()
    output_file.close()
    comment_floating_asl(fatherfile + '.tmp')
    shutil.move(fatherfile + '.tmp', fatherfile)
    return None


def edit_psr_wordmanipulation(uasl_files):
    if 'ArmProgramStatusRegister' in uasl_files:
        uasl_files.remove('ArmProgramStatusRegister')
    else:  # This means that it was uncommented!
        switch_library('ArmProgramStatusRegister', 'Yes')
    if 'ArmWordManipulation' in uasl_files:
        uasl_files.remove('ArmWordManipulation')
    else:
        switch_library('ArmWordManipulation', 'Yes')
    # This could be implemented in switch_library as return value if nothing
    # changed, but for now, use quick and resource hungry solution
    check_list = list_used_asl_files()
    if not ('ArmWordManipulation' in check_list and
            'ArmProgramStatusRegister' in check_list):
        return False
    return True


def main():
    uasl_files = list_used_asl_files()
    # The user does not need to know, that PSR and WordManipulation exist
    correct_edit = edit_psr_wordmanipulation(uasl_files)
    if not correct_edit:
        return('Missing ArmWordManipulation or '
               'ArmProgramStatusRegister in ArmDataPath!')

    if not uasl_files:
        uasl_str = '   --- NONE are being used from ARM_SIM_LIB ---'
    else:
        uasl_str = '\n'.join(uasl_files)
    backup()
    switch_to_asl = buttonbox('Do you want to switch your modules\nwith the '
                              'ones from HWPTI?', title=title, choices=choices)
    if switch_to_asl is None:
        return 'User pressed X'

    # Extra code to prepare for synthesis!
    # This will comment all ARM_SIM_LIB's out but will not uncomment
    # work -> This is exactly what needs to be done to prepare for synthesis
    # This will not make a difference if the original comments aren't changed
    if switch_to_asl == choices[2]:
        replace_all_arm_types('No, do the opposite')
        for module in moduleEdit:
            switch_library(module, 'No, prepare for synthesis')
        return 'Ready for synthesis.'
    ####################################################################

    if switch_to_asl == 'Yes':
        sec_title_asl = 'Which Modules should be imported from ARM_SIM_LIB?\n'
    else:
        sec_title_asl = 'Which Modules should be used from your own library?\n'

    # The user does not need to know, that PSR and WordManipulation exist
    moduleEdit.remove('ArmProgramStatusRegister')
    moduleEdit.remove('ArmWordManipulation')
    moduleList = multchoicebox(sec_title_asl + used_str +
                               uasl_str,
                               choices=moduleEdit, title=title)
    if moduleList is None:
        return 'User cancelled Box'

    moduleList.append('ArmProgramStatusRegister')
    moduleList.append('ArmWordManipulation')
    for module in moduleList:
        switch_library(module, switch_to_asl)

    if 'ArmRegfile' in moduleList:
        switch_library('ArmGlobalProbes', switch_to_asl,
                       modified_fatherfile='ArmCore_tb.vhd')
    if 'ArmMemInterface' in moduleList:
        switch_library('ArmMemInterface', switch_to_asl,
                       modified_fatherfile='ArmCore_tb.vhd')

    if 'ArmArithInstructionCtrl' in moduleList:
        replace_all_arm_types(switch_to_asl)

    # Unsupporting ArmRegAddressTranslation because it
    # CAN be used in Regfile, but
    # it doesn't HAS to be used => Would need to add ARM_SIM_LIB in those files
    # if 'ArmRegAddressTranslation' in moduleList:
    #     switch_library('ArmRegAddressTranslation', switch_to_asl,
    #                    modified_fatherfile='ArmCore_tb.vhd')

    return 'Exited normally.'


if __name__ == '__main__':
    if sys.version_info < (3, 0):
        sys.stdout.write('Sorry, requires Python 3.x, not Python 2.x\n'
                         'Call script with \"python3 '
                         'ChangeLib_Win_Support.py\"\n')
        sys.exit(1)
    status = main()
    sys.exit(status)
