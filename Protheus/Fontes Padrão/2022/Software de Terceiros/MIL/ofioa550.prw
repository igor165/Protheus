// …ÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕÕª
// ∫ Versao ∫ 5      ∫
// »ÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕÕº

#include "Protheus.ch" 
#include "OFIOA550.ch" 

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFIOA550   | Autor |  Takahashi            | Data | 13/08/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Garantia Mutua                                               |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIOA550(xAuto,nOpcAuto)

Local cAlias

Private lOA550Auto := ( xAuto <> NIL )

cAlias := "VDF"
chkFile(cAlias)
dbSelectArea(cAlias)
dbSetOrder(1)

Private cCadastro := STR0001
Private aRotina := MenuDef()
Private aCores  := {{ 'VDF->VDF_STATUS == "P"', 'BR_AMARELO'  } ,;  // Pendente Liberacao
					{ 'VDF->VDF_STATUS == "L"', 'BR_VERDE'    } ,;  // Liberado
					{ 'VDF->VDF_STATUS == "R"', 'BR_VERMELHO' } ,;  // Rejeitado
					{ 'VDF->VDF_STATUS == "C"', 'BR_PRETO'    } }   // Cancelado

dbSelectArea(cAlias)

If lOA550Auto
	aAuto := xAuto
	mBrowseAuto( nOpcAuto , aClone(aAuto) , cAlias , .f. , .t. )
Else
	mBrowse( 6, 1, 22, 75, cAlias,,,,,,aCores)
EndIf

return


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OA550LIB   | Autor | Takahashi             | Data | 13/08/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Liberar o Pedido de Garantia Mutua                           |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA550LIB( cAlias , nReg , nOpc )
OA550ATU( "L" , cAlias , nReg , nOpc )
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OA550REJ   | Autor | Takahashi             | Data | 13/08/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Rejeita o Pedido de Garantia Mutua                           |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA550REJ( cAlias , nReg , nOpc )
OA550ATU( "R" , cAlias , nReg , nOpc )
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OA550ATU   | Autor | Takahashi             | Data | 13/08/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Atualiza o Status do Pedido de Garantia Mutua                |##
##+----------+--------------------------------------------------------------+##
##|Parametros| cOper = "L" - Libera o pedido                                |##
##|          |         "R" - Rejeita o pedido                               |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OA550ATU( cOper, cAlias , nReg , nOpc )

Local aCpoVDF 
Local aCpoVDFAlt
Local oSize

Local cTudoOk := ".t."
Local cATela := ""
Local lNoFolder := .t.
Local lProperty := .f.

Local aSizeAut	:= MsAdvSize(.t.)

Private aTELA[0][0]
Private aGETS[0]

dbSelectArea("VDF")
dbGoTo(nReg)

If !SoftLock(cAlias)
	Return 
EndIf

If VDF->VDF_STATUS <> "P"
	MsgStop(STR0002)	// "N„o È possÌvel alterar pedido de garantia com status diferente de Pendente LiberaÁ„o."
	VDF->(MsUnLock())
	Return
EndIf

RegToMemory(cAlias,.f.,.f.)

aCpoVDF := {}
aCpoVDFAlt := {}

SX3->(dbSetOrder(1))
SX3->(dbSeek("VDF"))
While !SX3->(Eof()) .and. (SX3->X3_ARQUIVO=="VDF")
	If X3USO(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .and. !(SX3->X3_CAMPO $ "VDF_CHAINT/VDF_STATUS/")
		AADD(aCpoVDF,SX3->X3_CAMPO)
	EndIf
	If (cOper $ "L/R" .and. Alltrim(SX3->X3_CAMPO) $ "VDF_OBSERV" ) .OR. SX3->X3_PROPRI == "U"
		aAdd(aCpoVDFAlt,SX3->X3_CAMPO)
	EndIf
	SX3->(DbSkip())
Enddo

// Liberar 
If cOper == "L"
	M->VDF_DATLIB := dDataBase
	M->VDF_HORLIB := Left(Time(),5)
// Rejeitar
ElseIf cOper == "R"
	M->VDF_DATREJ := dDataBase
	M->VDF_HORREJ := Left(Time(),5)
EndIf

nOpcA := 0
If !lOA550Auto
	DEFINE MSDIALOG oDlgGarMut TITLE cCadastro FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] PIXEL OF oMainWnd

	oEnchVDF := MSMGet():New( cAlias, nReg, 4 ,;
		/* aCRA */, /* cLetra */, /* cTexto */, aCpoVDF,  , aCpoVDFAlt, ,;
		/* nColMens */, /* cMensagem */, cTudoOk, oDlgGarMut, , , .f. /* lColumn */ ,;
		, .f. /* lNoFolder */, )
	oEnchVDF:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlgGarMut ON INIT EnchoiceBar(oDlgGarMut,{|| IIf( OA550TUDOK(cOper, nReg) , (nOpcA := 1 , oDlgGarMut:End()) , .f. )} , {|| nOpcA := 0 , oDlgGarMut:End() })
Else
	If EnchAuto( cAlias , aAuto, { || OA550TUDOK( cOper , nReg ) } , nOpc , aAuto )
		nOpcA := 1
	Endif
EndIf

If nOpcA == 1
	OA550GRV(cOper, nReg)
EndIf

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OA550TUDOK | Autor | Takahashi             | Data | 13/08/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Validacao para gravacao dos dados                            |##
##+----------+--------------------------------------------------------------+##
##|Parametros| cOper = "L" - Libera o pedido                                |##
##|          |         "R" - Rejeita o pedido                               |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OA550TUDOK(cOper, nReg)

If cOper == "R" .and. Empty(M->VDF_OBSERV)
	Help(1," ","OBRIGAT",,RetTitle("VDF_OBSERV"),4,1)
	Return .f.
EndIf

Return .t. 


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OA550GRV   | Autor | Takahashi             | Data | 13/08/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Gravacao dos dados                                           |##
##+----------+--------------------------------------------------------------+##
##|Parametros| cOper = "L" - Libera o pedido                                |##
##|          |         "R" - Rejeita o pedido                               |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OA550GRV(cOper, nReg)

Local cSQL

Begin Transaction 
dbSelectArea("VDF")
dbGoTo(nReg)

If !RecLock("VDF",.f.)
	Help("  ",1,"REGNLOCK")
	DisarmTransaction()
	Return .f.
EndIf
FG_GRAVAR("VDF")
VDF->VDF_STATUS := cOper
MSMM(VDF->VDF_OBSMEM,TamSx3("VDF_OBSERV")[1],,M->VDF_OBSERV,1,,,"VDF","VDF_OBSMEM")
MsUnLock()
    
// Se foi rejeitado, altera a OS ...               
If cOper == "R"

	// Verifica se existe alguma solicitacao pendente liberacao ou liberada
	// senao encontrar, marca a garantia mutua na OS como rejeitada ...
	cSQL := "SELECT COUNT(*) "
	cSQL +=  " FROM " + RetSQLName("VDF") 
	cSQL += " WHERE VDF_FILIAL = '" + xFilial("VDF") + "'" 
	cSQL +=   " AND VDF_NUMOSV = '" + VDF->VDF_NUMOSV + "'"
	cSQL +=   " AND VDF_NUMPED <> '" + VDF->VDF_NUMPED + "'"
	cSQL +=   " AND VDF_STATUS IN ('P','L') "
	cSQL +=   " AND D_E_L_E_T_ = ' '"
	If FM_SQL(cSQL) == 0
		dbSelectArea("VO1")
		dbSetOrder(1)
		dbSeek( xFilial("VO1") + VDF->VDF_NUMOSV )
		If !RecLock("VO1",.f.)
			HELP(" ",1,"REGBLOQ")
			DisarmTransaction()
			Return .f.
		EndIf
		VO1->VO1_GARMUT := "2"
		MsUnLock()
	EndIf
EndIf
//

If ExistBlock("OA550DGR")
	ExecBlock("OA550DGR",.f.,.f.)
EndIf

End Transaction

Return .t.


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OA550LEG   | Autor | Takahashi             | Data | 13/08/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Legenda                                                      |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA550LEG()

Local aLegenda  := {{ 'BR_AMARELO' , STR0003 } ,; // "Pendente LiberaÁ„o"
					{ 'BR_VERDE'   , STR0004 } ,; // "Liberado"
					{ 'BR_VERMELHO', STR0005 } ,; // "Rejeitado"
					{ 'BR_PRETO'   , STR0006 }}   // "Cancelado"

BrwLegenda(cCadastro,STR0007,aLegenda) //Legenda

Return



/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OA550INC   | Autor | Takahashi             | Data | 13/08/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Inclusao do Pedido de Garantia Mutua                         |##
##+----------+--------------------------------------------------------------+##
##|Parametros| cNumOsv = Numero da Ordem de Servico de Garantia             |##
##|          | cNumOrc = Numero do Orcamento com pecas e servicos da gar.   |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA550INC(cNumOsv, cNumOrc, nVlrEstim, lPergunta)

Local aArea := {}
Local aAreaAtu
Local lRetorno := .f.
Local cSQL
Local cSQLBase
Local nAuxRecno := 0
Local cAliasVDF := "TVDF"
Local cMsg
Local cQuebra
Local cPedidos := ""
Local nValor   := 0
Local nSubValor := 0
Local nRespAviso := 0
Local aRetParam := {}

Default cNumOrc := ""
Default nVlrEstim := 0
Default lPergunta := .f.

aAreaAtu := GetArea()

cSQLBase := "SELECT R_E_C_N_O_ RECNO"
cSQLBase += " FROM " + RetSQLName("VDF")
cSQLBase += " WHERE VDF_FILIAL = '" + xFilial("VDF") + "'"
cSQLBase +=   " AND D_E_L_E_T_ = ' ' "
cSQLBase +=   " AND VDF_STATUS IN ('P','L') "

// Se for passado um numero de orcamento, procura qualquer solicitacao para a mesma os sem numero de orcamento 
// ou o numero do orcamento  
If !Empty(cNumOrc)
	cSQL := cSQLBase 
	cSQL += " AND VDF_NUMOSV = '" + cNumOsv + "'"
	cSQL += " AND VDF_NUMORC = '" + cNumOrc + "'"
	nAuxRecno := FM_SQL(cSQL)
	
	// Se nao encontrar registro, procura um registro com o mesmo
	// numero de OS e sem orcamento gravado, pois se trata de uma
	// solicitacao de garantia criada pela Abertura de OS
	If nAuxRecno == 0
		cSQL := cSQLBase 
		cSQL += " AND VDF_NUMOSV = '" + cNumOsv + "'"
		cSQL += " AND VDF_NUMORC = '        '"
		nAuxRecno := FM_SQL(cSQL)
		// Se encontrar o registro, pergunta se o usuario deseja criar
		// um novo registro relacionando com o orcamento ...
		If /* nAuxRecno <> 0 .and. */ lPergunta

			cMsg := ""
					
			cSQL := "SELECT VDF_NUMPED, VDF_VLREST , VDF_STATUS "
			cSQL += " FROM " + RetSQLName("VDF")
			cSQL += " WHERE VDF_FILIAL = '" + xFilial("VDF") + "'"
			cSQL +=   " AND VDF_NUMOSV = '" + cNumOsv + "'"
			cSQL +=   " AND VDF_STATUS IN ('P','L')"
			cSQL +=   " AND D_E_L_E_T_ = ' '"
			cSQL += " ORDER BY VDF_STATUS,VDF_NUMPED"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVDF , .F., .T. ) 			
			cQuebra := (cAliasVDF)->VDF_STATUS
			While !(cAliasVDF)->(Eof())
			
				cPedidos += (cAliasVDF)->VDF_NUMPED + "/"
				nSubValor += (cAliasVDF)->VDF_VLREST
			
				(cAliasVDF)->(dbSkip())
				
				If (cAliasVDF)->(Eof()) .or. cQuebra <> (cAliasVDF)->VDF_STATUS
					cMsg += AllTrim(RetTitle("VDF_STATUS")) + ": " + X3CBOXDESC("VDF_STATUS",cQuebra) + chr(13) + chr(10)
					cMsg += AllTrim(RetTitle("VDF_NUMPED")) + ": " + Left(cPedidos,Len(cPedidos)-1) + chr(13) + chr(10)
					cMsg += AllTrim(RetTitle("VDF_VLREST")) + ": " + Transform(nSubValor,PesqPict("VDF","VDF_VLREST")) + chr(13) + chr(10) + chr(13) + chr(10)
					nValor += nSubValor
					cPedidos := ""
					nSubValor := 0
					cQuebra := IIf( !(cAliasVDF)->(Eof()) , (cAliasVDF)->VDF_STATUS , "")
				EndIf
			End
			(cAliasVDF)->(dbCloseArea())
			dbSelectArea("VDF")
			
			If !Empty(cMsg)
				cMsg := STR0013 + chr(13) + chr(10) + chr(13) + chr(10) + cMsg // "Existe uma solicitaÁ„o de garantia criada para a OS."
			Else
				cMsg := STR0018 + chr(13) + chr(10) + cMsg // "OS de garantia m˙tua mas ainda n„o possui solicitaÁ„o gerada."
			EndIf
			cMsg += chr(13) + chr(10) + STR0017 + ": " + Transform(nValor,PesqPict("VDF","VDF_VLREST")) + chr(13) + chr(10) + chr(13) + chr(10) // "Total estimado"
			cMsg += STR0016 // "Deseja criar uma nova solicitaÁ„o relacionando este orÁamento ou continuar a exportaÁ„o?"
			
			nRespAviso := Aviso(STR0012, cMsg , {STR0014 , STR0015 },3) // "Nova Sol.","Continuar"
			
			If nRespAviso == 1
				nAuxRecno := 0
			Else
				nAuxRecno := -1
			EndIf
				
		Endif
	EndIf
	
	If ExistBlock("OA550VLD")
		//TODO Tratar o retorno do PE para possibilitar o usuario cancelar a exportaÁ„o do orcamento  
		ExecBlock("OA550VLD",.F.,.F., { nRespAviso } )
	EndIf	
	
Else
	cSQL := cSQLBase + " AND VDF_NUMOSV = '" + cNumOsv + "'"
	nAuxRecno := FM_SQL(cSQL)
EndIf

If nAuxRecno == 0

	aArea := sGetArea(aArea,"VV1")
	aArea := sGetArea(aArea,"VO1")
	aArea := sGetArea(aArea,"VG4")
	
	If !Empty(cNumOrc)

		// Pede valor estimado 
		aParParam := {{1,AllTrim(RetTitle("VDF_VLREST")),0,"@E 999,999,999.99","","","",50,.t.}}
		While .t.
			If ParamBox(aParParam,STR0001,aRetParam,,,,,,,,.f.)
				nVlrEstim := aRetParam[1]
				Exit
			EndIf
		End
		//
		
	EndIf
	
	VO1->(dbSetOrder(1))
	VO1->(MsSeek( xFilial("VO1") + cNumOsv ))

	VV1->(dbSetOrder(1))
	VV1->(MsSeek( xFilial("VV1") + VO1->VO1_CHAINT ))
	
	BEGIN TRANSACTION
	
	VG4->(dbSetOrder(1))
	If !VG4->(dbSeek(xFilial("VG4") + Str(Year(dDataBase),4) + "MUT"))
		dbSelectArea("VG4")
		RecLock("VG4",.t.)
		VG4->VG4_FILIAL := xFilial("VG4")
		VG4->VG4_ANONRO := Str(Year(dDataBase),4)
		VG4->VG4_CODMAR := "MUT"
		VG4->VG4_NUMERO := StrZero(1,TamSX3("VG4_NUMERO")[1])
	Else
		RecLock("VG4",.f.)
		VG4->VG4_NUMERO := Soma1(VG4->VG4_NUMERO)
	EndIf
	
	dbSelectArea("VDF")
	RegToMemory("VDF",.t.,.t.)	// Inicializa M-> 
	RecLock("VDF",.t.)
	FG_GRAVAR("VDF")
	VDF->VDF_FILIAL := xFilial("VDF")
	VDF->VDF_ANOPED := Str(Year(dDataBase),4)
	VDF->VDF_NUMPED := VG4->VG4_NUMERO
	VDF->VDF_STATUS := "P"
	VDF->VDF_CHAINT := VO1->VO1_CHAINT
	VDF->VDF_NUMOSV := cNumOsv
	VDF->VDF_NUMORC := cNumOrc
	cCodCli := ""
	cCodLoja := ""
	if !Empty(cNumOrc)
		VS1->(DBSetOrder(1))
		VS1->(DBSeek(xFilial("VS1") + cNumOrc))
		cCodCli := IIF(!Empty(VS1->VS1_CLIFAT), VS1->VS1_CLIFAT, cCodCli)
		cCodLoja := IIF(!Empty(VS1->VS1_LOJA),VS1->VS1_LOJA, cCodLoja)
	endif
	if Empty(cCodCli)
		cCodCli := IIF(!Empty(VO1->VO1_FATPAR), VO1->VO1_FATPAR, VO1->VO1_PROVEI)
		cCodLoja   := IIF(!Empty(VO1->VO1_LOJA),VO1->VO1_LOJA, VO1->VO1_LOJPRO)
	endif
	VDF->VDF_CODCLI := cCodCli
	VDF->VDF_LOJA   := cCodLoja
	
	VDF->VDF_CODCON := VV1->VV1_CODCON
	VDF->VDF_VLREST := nVlrEstim
	VDF->(MsUnLock())
	
	VG4->(MsUnLock())
	
	END TRANSACTION
	
	lRetorno := .t.
	
	// Ponto de Entrada de Formulario de Garantia Mutua 
	If ExistBlock("OA550SGM")
		ExecBlock("OA550SGM",.f.,.f.)
	EndIf
	//	
	
EndIf

If Len(aArea) > 0
	sRestArea(aArea)
Endif
RestArea(aAreaAtu)

Return lRetorno




/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OA550STAT  | Autor | Takahashi             | Data | 13/08/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Retorna o Status do Pedido de Garantia Mutua                 |##
##+----------+--------------------------------------------------------------+##
##|Parametros| cNumOsv = Numero da Ordem de Servico de Garantia             |##
##|          | cNumOrc = Numero do Orcamento com pecas e servicos da gar.   |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA550STAT(cNumOsv, cNumOrc)

Local cSQL := ""

cSQL := "SELECT VDF_STATUS "
cSQL +=  " FROM " + RetSQLName("VDF") + " VDF "
cSQL += " WHERE VDF_FILIAL = '" + xFilial("VDF") + "'"
If !Empty(cNumOsv)
	cSQL +=   " AND VDF_NUMOSV = '" + cNumOsv + "'"
EndIf
If !Empty(cNumOrc)
	cSQL +=   " AND VDF_NUMORC = '" + cNumOrc + "'"
EndIf
cSQL +=   " AND VDF_STATUS IN ('P','L') "
cSQL +=   " AND D_E_L_E_T_ = ' '"

Return (FM_SQL(cSQL))

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OA550NUMOS | Autor | Takahashi             | Data | 13/08/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Retorna o Numero da OS de Gar. Mutua de um determinado orcam.|##
##+----------+--------------------------------------------------------------+##
##|Parametros| cNumOrc = Numero do Orcamento com pecas e servicos da gar.   |##
##|          | cStatus = Filtra por status do Pedido (informar valores      |##
##|          |           separados por ',')                                 |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA550NUMOS( cNumOrc , cStatus )

Local cSQL := ""
Local cNumOsv := ""

Default cStatus := ""

cSQL := "SELECT VDF_NUMOSV "
cSQL +=  " FROM " + RetSQLName("VDF") + " VDF "
cSQL += " WHERE VDF_FILIAL = '" + xFilial("VDF") + "'"
cSQL +=   " AND VDF_NUMORC = '" + cNumOrc + "'"
If !Empty(cStatus)
	cSQL +=   " AND VDF_STATUS IN " + FormatIN(cStatus,",")
EndIf
cSQL +=   " AND D_E_L_E_T_ = ' '"

cNumOsv := FM_SQL(cSQL)

Return cNumOsv

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OA550CANPED| Autor | Takahashi             | Data | 13/08/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Cancela o pedido de garantia mutua                           |##
##+----------+--------------------------------------------------------------+##
##|Parametros| cNumOrc = Numero do Orcamento com pecas e servicos da gar.   |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OA550CANPED( cNumOrc , cNumOsv )

Local lRetorno := .f.
Local aArea := {}

Default cNumOrc := ""
Default cNumOsv := ""

sGetArea(aArea,Alias())

If !Empty(cNumOrc)
	VDF->(dbSetOrder(3))
	If !VDF->(dbSeek(xFilial("VDF") + cNumOrc))
		lRetorno := .t.
	Else
		If !RecLock("VDF",.F.,.T.)
			lRetorno := .f.
		Else
			dbSelectArea("VDF")
			VDF->VDF_STATUS := "C"
			VDF->VDF_DATCAN := dDataBase
			VDF->VDF_HORCAN := Left(Time(),5)
			MsUnLock()
			lRetorno := .t.
		EndIf
	EndIf
EndIf


If !Empty(cNumOsv)
	VDF->(dbSetOrder(2))
	If !VDF->(dbSeek(xFilial("VDF") + cNumOsv))
		lRetorno := .t.
	Else
		While !VDF->(Eof()) .and. VDF->VDF_FILIAL == xFilial("VDF") .and. VDF->VDF_NUMOSV == cNumOsv
			If !RecLock("VDF",.F.,.T.)
				lRetorno := .f.
				Exit
			Else
				dbSelectArea("VDF")
				VDF->VDF_STATUS := "C"
				VDF->VDF_DATCAN := dDataBase
				VDF->VDF_HORCAN := Left(Time(),5)
				MsUnLock()
				lRetorno := .t.
			EndIf
			VDF->(dbSkip())
		EndDo
	EndIf
EndIf

sRestArea(aArea)

Return lRetorno

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OA550LEG   | Autor | Takahashi             | Data | 13/08/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Legenda                                                      |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function MenuDef()

Local aRotina := {;
	{ STR0008 , "AxPesqui", 0, 1},;	// "Pesquisar" 
	{ STR0009 , "AxVisual", 0, 2},;	// "Visualizar"
	{ STR0010 , "OA550LIB", 0, 4},;	// "Liberar"   
	{ STR0011 , "OA550REJ", 0, 4},;	// "Rejeitar"  
	{ STR0007 , "OA550LEG", 0, 4, 2 ,.f. };	// "Legenda"
	}
	
Return aRotina
