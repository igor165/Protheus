// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 5      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFIXI016.CH"

/*
================================================================================
################################################################################
##+----------+------------+-------+-----------------------+------+-----------+##
##|Função    | OFIXI016   | Autor | Thiago                | Data | 26/02/13  |##
##+----------+------------+-------+-----------------------+------+-----------+##
##|Descrição | Importação do arquivo de comunicação EDI com a montadora 	 |##
##|			 | MITSUBISHI veículos - Assunto TABELA DE PREÇO DE PEÇAS.		 |##
##+----------+---------------------------------------------------------------+##
##|Uso       |                                                               |##
##+----------+---------------------------------------------------------------+##
################################################################################
================================================================================
*/
Function OFIXI016()
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002

Local cDesc3  := STR0003
Local aSay := {}
Local aButton := {}

Private cTitulo := ""
Private cPerg := "OXI016" 	// TODO - Pergunte
Private lErro := .f.  	    // Se houve erro, não move arquivo gerado
Private cArquivo			// Nome do Arquivo a ser importado
Private aLinhasRel := {}	// Linhas que serão apresentadas no relatorio

if TamSX3("B1_CODITE")[1] < 17
	MsgInfo(STR0012)
	return .f.
endif
//
aAdd( aSay, cDesc1 ) // Um para cada cDescN
aAdd( aSay, cDesc2 ) // Um para cada cDescN
aAdd( aSay, cDesc3 ) // Um para cada cDescN
//
nOpc := 0
aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )
//
// mv_par01 - Local do Arquivo
// mv_par02 - Grupo a Atualizar
// mv_par03 - Marca 
// mv_par04 - Atualiza Aliquotas de Impostos (1 = Sim / 2 = Não)
//
FormBatch( cTitulo, aSay, aButton )
//
If nOpc <> 1
	Return
Endif
//
Pergunte(cPerg,.f.)
//
RptStatus( {|lEnd| ImportArq(@lEnd)},"",STR0004)

//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | ImportArq  | Autor | Thiago                | Data | 26/02/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Importar arquivo.									        |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ImportArq()
//
Local cGruVei  := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
Local cAuxGrupo := MV_PAR02

if Empty(mv_par01)
	MsgInfo(STR0005)
	Return(.f.)
Endif
cGrpIte := "VW  "
//
DBSelectArea("VE4")
DBSetOrder(1)
DBSeek(xFilial("VE4") + MV_PAR03 )
cAlmox  := VE4->VE4_ALMPAD
	
If File(mv_par01)
	
	if (nHandle:= FT_FUse( mv_par01 )) == -1
		Return
	EndIf
	
	FT_FGotop()
	lRet := .f.
	While ! FT_FEof()
		
		cStr := FT_FReadLN()
		If !Empty(cStr)
			cOpcao := substr(cStr,136,2)
			if !Empty(cAuxGrupo)
				dbSelectArea("SB1")
				dbSetOrder(1)
				if !dbSeek(xFilial("SB1")+substr(cStr,1,18))
					aIncSB1:= {}
					aAdd(aIncSB1,{"B1_COD"    , substr(cStr,1,18)            ,Nil})
					aAdd(aIncSB1,{"B1_CODITE" , substr(cStr,1,18)            ,Nil})
					aAdd(aIncSB1,{"B1_GRUPO"  , cAuxGrupo                    ,Nil})
					aAdd(aIncSB1,{"B1_TIPO"   , "ME"                         ,Nil}) // Tipo do Produto
					aAdd(aIncSB1,{"B1_UM"     , "PC"                         ,Nil}) //
					aAdd(aIncSB1,{"B1_PRV1"   , val(substr(cStr,82,10))/100  ,Nil})
					aAdd(aIncSB1,{"B1_DESC"   , substr(cStr,37,40)           ,Nil})
					aAdd(aIncSB1,{"B1_POSIPI" , Alltrim(substr(cStr,123,13)) ,Nil})
					aAdd(aIncSB1,{"B1_LOCPAD" , cAlmox  				             ,Nil})
					If MV_Par04 == 1 // Sim -> Atualiza Aliquotas de Impostos
						//
						if cOpcao == "00" .or. cOpcao == "01" .or. cOpcao == "06" .or. cOpcao == "08" .or. cOpcao == "12" .or. cOpcao == "14"
							aAdd(aIncSB1,{"B1_IPI"  , 0   ,Nil})
						Else
							aAdd(aIncSB1,{"B1_IPI"  , val(substr(cStr,78,4))/100     ,Nil})
						Endif
						//
						if cOpcao == "00" .or. cOpcao == "02" .or. cOpcao == "04" .or. cOpcao == "13" .or. cOpcao == "14"
							aAdd(aIncSB1,{"B1_PPIS"  , 2.30     ,Nil})
							aAdd(aIncSB1,{"B1_PCOFINS"  , 10.80     ,Nil})
							if cOpcao == "13"
								aAdd(aIncSB1,{"B1_PICMENT"  , 40     ,Nil})
							Elseif cOpcao == "14"
								aAdd(aIncSB1,{"B1_PICMENT"  , 40     ,Nil})
							Endif
						Elseif cOpcao == "01" .or. cOpcao == "03" .or. cOpcao == "05" .or. cOpcao == "06" .or. cOpcao == "07" .or. cOpcao == "11" .or. cOpcao == "12"
							aAdd(aIncSB1,{"B1_PPIS"  , 1.65    ,Nil})
							aAdd(aIncSB1,{"B1_PCOFINS"  , 7.60     ,Nil})
							if cOpcao == "11"
								aAdd(aIncSB1,{"B1_PICMENT"  , 40     ,Nil})
							Elseif cOpcao == "12"
								aAdd(aIncSB1,{"B1_PICMENT"  , 40     ,Nil})
							Endif
						Elseif cOpcao == "08" .or. cOpcao == "10"
							aAdd(aIncSB1,{"B1_PICMENT"  , 42     ,Nil})
						Endif
						//
					Endif
					lMSHelpAuto := .t.
					lMSErroAuto := .f.
					MSExecAuto({|x| mata010(x)},aIncSB1)
					
					if lMSErroAuto
						MostraErro()
						DisarmTransaction()
						Break
					endif
					RecLock("SB5",.t.)
					SB5->B5_FILIAL := xFilial("SB5")
					SB5->B5_COD    := substr(cStr,1,18)
					SB5->B5_PRV2   := val(substr(cStr,92,10))/100
					SB5->B5_PRV3   := val(substr(cStr,102,10))/100
					MsUnlock()
					
				Else
					RecLock("SB1",.f.)
					SB1->B1_DESC   := substr(cStr,37,40)
					SB1->B1_PRV1   := val(substr(cStr,82,10))/100
					SB1->B1_POSIPI := Alltrim(substr(cStr,123,13))
					MsUnlock()
					dbSelectArea("SB5")
					dbSetOrder(1)
					if dbSeek(xFilial("SB5")+substr(cStr,1,18))
						RecLock("SB5",.f.)
						SB5->B5_FILIAL := xFilial("SB5")
						SB5->B5_COD    := substr(cStr,1,18)
						SB5->B5_PRV2   := val(substr(cStr,92,10))/100
						SB5->B5_PRV3   := val(substr(cStr,102,10))/100
						MsUnlock()
					Endif
				Endif
			Else
				MsgStop(STR0011)
				Return(.f.)
			Endif
		EndIf
		FT_FSkip()
	End
	FT_FUse()
	
Endif


MsgInfo(STR0006)
return

