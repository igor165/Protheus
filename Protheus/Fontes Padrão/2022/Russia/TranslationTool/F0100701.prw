#INCLUDE "PROTHEUS.CH"

/** Aplica as traduções no flavour
 */

User Function F0100701(aEmp)

    InitProc(aEmp)

    U_F0100401() // Cria os ResX
    U_F0100402() // Envia para Abby: se não existe, cria. Se já existe, atualiza.
    U_F0100501() // Faz o download dos documentos já traduzidos e atualiza os registros.
    
    ClearProc()

Return

Static Function InitProc(aEmp)

    Default aEmp := {"99", "01"}

    Static lInitialize := .F.

    If Select("SX2") == 0
        lInitialize := .T.
        RPCSetEnv(aEmp[1], aEmp[2])
    EndIf

Return

Static Function ClearProc()

    If lInitialize 
	    RpcClearEnv()
        lInitialize := Nil
    EndIf

Return
// Russia_R5
