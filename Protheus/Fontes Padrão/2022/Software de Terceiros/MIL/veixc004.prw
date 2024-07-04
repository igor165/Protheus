// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 09     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "VEIXC004.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEIXC004 º Autor ³ Luis Delorme       º Data ³  20/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Consulta Progresso de Veiculos                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXC004(aModProg,lFazAss)
Local aObjects  := {}, aInfo := {}, aPos := {}, nCntFor
Local aSizeHalf := MsAdvSize(.t.)
Local aRet      := {}
Local cQryAlias := "SQLVJ1"
Local cPedido   := space(len(VJ1->VJ1_CODPED))
Local aOrd      := {STR0004,STR0005,STR0006,(STR0012+"/"+STR0013),STR0008,STR0009} // Dt.Funilaria / Prev.Entrega / Pedido / Marca/Modelo / Cor / Opcionais
Local cOrd      := STR0004 // Dt.Funilaria
Local aIteP     := {}
Private oFnt1   := TFont():New( "System", , 12 )
Private oFnt2   := TFont():New( "Courier New", , 16,.t. )
Private oFnt3   := TFont():New( "Arial", , 14,.t. )
Private aIteRelP := {}
Default aModProg := {}
Default lFazAss  := .f.
If len(aModProg) <= 0
	MsgStop(STR0001+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0003,STR0002) // Consulta Progresso de Veiculos / Marca/Modelo nao selecionados! / Atencao
	return(aRet)
EndIf
// ########################################################################
// # Montagem das informacoes de posicionamento da consulta               #
// ########################################################################
For nCntFor := 1 to Len(aSizeHalf)
	aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.8)
Next
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 }// Tamanho total da tela
AAdd( aObjects, { 0, 0, .T., .T. } )
aPos := MsObjSize( aInfo, aObjects )
dyc := (aPos[1,4] - aPos[1,2])
// ########################################################################
// # Montagem da listbox contendo informacoes dos itens relacionados      #
// ########################################################################
For nCntFor := 1 to Len(aModProg)
	cQuery := "SELECT VJ1.*, VV2.VV2_DESMOD "
	cQuery += " FROM " + RetSqlName("VJ1") + " VJ1 "
	cQuery += " JOIN " + RetSQLName("VV2") + " VV2 ON VV2.VV2_FILIAL = '" + xFilial("VV2") + "' AND VV2.VV2_CODMAR = VJ1.VJ1_CODMAR AND VV2.VV2_MODVEI = VJ1.VJ1_MODVEI AND VJ1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE VJ1.VJ1_FILIAL='"+xFilial("VJ1")+"'"
	cQuery +=   " AND VJ1.VJ1_CODMAR='"+aModProg[nCntFor,1]+"'"
	cQuery +=   " AND VJ1.VJ1_MODVEI IN ("+aModProg[nCntFor,2]+")"
	cQuery +=   " AND VJ1.VJ1_NUMNFI='000000'" // Exibe somente os que nao tiver nota da FABRICA
	cQuery +=   " AND VJ1.VJ1_NUMTRA=' '"
	cQuery +=   " AND VJ1.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias, .F., .T. )
	while !(cQryAlias)->(eof())
		aIteP := {}
		aAdd(aIteP,UPPER((cQryAlias)->(VJ1_CODPED)))
		aAdd(aIteP,(cQryAlias)->(VJ1_CODMAR))
		aAdd(aIteP,(cQryAlias)->(VJ1_MODVEI))
		aAdd(aIteP,(cQryAlias)->(VV2_DESMOD))
		aAdd(aIteP,(cQryAlias)->(VJ1_NUMTRA))
		DBSelectArea("VVC")
		DBSetOrder(1)
		if DBSeek(xFilial("VVC")+(cQryAlias)->(VJ1_CODMAR)+STRZERO((cQryAlias)->(VJ1_COREXT),2))
			aAdd(aIteP,VVC->VVC_DESCRI)
		else
			aAdd(aIteP,"N/D")
		endif
		cOpcVJ1 := Alltrim((cQryAlias)->(VJ1_OPC001)+"/"+(cQryAlias)->(VJ1_OPC002)+"/"+(cQryAlias)->(VJ1_OPC003)+"/"+(cQryAlias)->(VJ1_OPC004)+"/"+(cQryAlias)->(VJ1_OPC005);
					+"/"+(cQryAlias)->(VJ1_OPC006)+"/"+(cQryAlias)->(VJ1_OPC007)+"/"+(cQryAlias)->(VJ1_OPC008)+"/"+(cQryAlias)->(VJ1_OPC009)+"/"+(cQryAlias)->(VJ1_OPC010);
					+"/"+(cQryAlias)->(VJ1_OPC011)+"/"+(cQryAlias)->(VJ1_OPC012)+"/"+(cQryAlias)->(VJ1_OPC013)+"/"+(cQryAlias)->(VJ1_OPC014)+"/"+(cQryAlias)->(VJ1_OPC015);
					+"/"+(cQryAlias)->(VJ1_OPC016)+"/"+(cQryAlias)->(VJ1_OPC017)+"/"+(cQryAlias)->(VJ1_OPC018)+"/"+(cQryAlias)->(VJ1_OPC019)+"/"+(cQryAlias)->(VJ1_OPC020);
					+"/"+(cQryAlias)->(VJ1_OPC021)+"/"+(cQryAlias)->(VJ1_OPC022)+"/"+(cQryAlias)->(VJ1_OPC023)+"/"+(cQryAlias)->(VJ1_OPC024))
		while Right(cOpcVJ1,1)=="/" .or. Right(cOpcVJ1,1)==" "
			cOpcVJ1 = Left(cOpcVJ1,Len(cOpcVJ1)-1)
		enddo
		aAdd(aIteP,cOpcVJ1)
		aAdd(aIteP,stod((cQryAlias)->(VJ1_DATFUN)))
		aAdd(aIteP,stod((cQryAlias)->(VJ1_DATPRO)))
		aAdd(aIteRelP,aIteP)
		(cQryAlias)->(DBSkip())
	enddo
	(cQryAlias)->(dbCloseArea())
Next
//
If Empty(aIteRelP)
	aIteRelP := {{"","","","","","","",ctod(""),ctod("")}}
EndIf

FS_ORDEM(cOrd,.f.) // Ordena Vetor 

DEFINE MSDIALOG oDlgCP FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0001 OF oMainWnd PIXEL // Consulta Progresso de Veiculos

@ aPos[1,1]+006,aPos[1,2]+003 SAY (STR0010+":") SIZE 50,8 OF oDlgCP PIXEL COLOR CLR_BLUE // Ordem
@ aPos[1,1]+005,aPos[1,2]+030 MSCOMBOBOX oOrd VAR cOrd SIZE 65,08 COLOR CLR_BLACK ITEMS aOrd OF oDlgCP ON CHANGE FS_ORDEM(cOrd,.t.) PIXEL COLOR CLR_BLUE

@ aPos[1,1]+006,aPos[1,2]+123 SAY (STR0011+":") SIZE 80,8 OF oDlgCP PIXEL COLOR CLR_BLUE // Pesquisa Nro.Pedido
@ aPos[1,1]+005,aPos[1,2]+183 MSGET oPedido VAR cPedido PICTURE "@!" SIZE 40,08 VALID FS_PEDIDO(cPedido) OF oDlgCP PIXEL COLOR CLR_BLUE

@ aPos[1,1]+021,aPos[1,2]+01 LISTBOX oLbIteRelP FIELDS HEADER ;
STR0004,; // Dt.Funilaria
STR0005,; // Prev.Entrega
STR0006,; // Pedido
STR0012,; // Marca
STR0013,; // Modelo
STR0007,; // Descricao
STR0014,; // Empenhado
STR0008,; // Cor
STR0009 ; // Opcionais
COLSIZES 0.07 * dyc , 0.07 * dyc , 0.05 * dyc, 0.04 * dyc, 0.08 * dyc, 0.20 * dyc, 0.07 * dyc, 0.15 * dyc, 0.40 * dyc ;
SIZE aPos[1,4] - aPos[1,2], aPos[1,3] - aPos[1,1] - 020 OF oDlgCP ON DBLCLICK IIf(!Empty(aIteRelP[oLbIteRelP:nAt,1]),(aRet := FS_VXC004(lFazAss),oDlgCP:End() ),.t.) PIXEL
oLbIteRelP:SetArray(aIteRelP)
oLbIteRelP:bLine := { || { Transform(aIteRelP[oLbIteRelP:nAt,8],"@D") ,;
Transform(aIteRelP[oLbIteRelP:nAt,9],"@D") ,;
aIteRelP[oLbIteRelP:nAt,1],;
aIteRelP[oLbIteRelP:nAt,2],;
aIteRelP[oLbIteRelP:nAt,3],;
aIteRelP[oLbIteRelP:nAt,4],;
aIteRelP[oLbIteRelP:nAt,5],;
aIteRelP[oLbIteRelP:nAt,6],;
aIteRelP[oLbIteRelP:nAt,7] }}
// ########################################################################
// # Verifica se houve passagem de parametro contendo algum codigo (SB1)  #
// ########################################################################
ACTIVATE MSDIALOG oDlgCP CENTER ON INIT (EnchoiceBar(oDlgCP,{|| aRet:=FS_VXC004(lFazAss),oDlgCP:End()},{ || oDlgCP:End()},,))
//
Return(aRet)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |  FS_ORDEM  | Autor | Andre Luis Almeida    | Data | 08/07/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o |  Ordena Vetor com os Veiculos de Progresso                   |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_ORDEM(cOrd,lRefresh)
Local aVetAux := {}
Local ni   := 0
If cOrd == STR0006 // Pedido
	Asort(aIteRelP,,,{|x,y| x[1] < y[1] })
ElseIf cOrd == (STR0012+"/"+STR0013) // Marca/Modelo
	Asort(aIteRelP,,,{|x,y| x[2]+x[3]+x[4]+x[1] < y[2]+y[3]+y[4]+y[1] })
ElseIf cOrd == STR0008 // Cor
	Asort(aIteRelP,,,{|x,y| x[6]+x[1]  < y[6]+y[1] })
ElseIf cOrd == STR0009 // Opcionais
	Asort(aIteRelP,,,{|x,y| x[7]+x[1] < y[7]+y[1] })
ElseIf cOrd == STR0004 // Dt.Funilaria
	Asort(aIteRelP,,,{|x,y| dtos(x[8])+dtos(x[9])+x[1] < dtos(y[8])+dtos(y[9])+y[1] })
	// Deixar Data Em Branco no Fim //
	For ni := 1 to len(aIteRelP)
		If !Empty(aIteRelP[ni,8])
			aadd(aVetAux,aClone(aIteRelP[ni]))
		EndIf
	Next
	For ni := 1 to len(aIteRelP)
		If Empty(aIteRelP[ni,8])
			aadd(aVetAux,aClone(aIteRelP[ni]))
		EndIf
	Next
	aIteRelP := aClone(aVetAux)
ElseIf cOrd == STR0005 // Prev.Entrega
	Asort(aIteRelP,,,{|x,y| dtos(x[9])+dtos(x[8])+x[1] < dtos(y[9])+dtos(y[8])+y[1] })
	// Deixar Data Em Branco no Fim //
	For ni := 1 to len(aIteRelP)
		If !Empty(aIteRelP[ni,9])
			aadd(aVetAux,aClone(aIteRelP[ni]))
		EndIf
	Next
	For ni := 1 to len(aIteRelP)
		If Empty(aIteRelP[ni,9])
			aadd(aVetAux,aClone(aIteRelP[ni]))
		EndIf
	Next
	aIteRelP := aClone(aVetAux)
EndIf
If lRefresh
	FS_REFRESH()
EndIf
Return()

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |  FS_PEDIDO | Autor | Andre Luis Almeida    | Data | 08/07/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o |  Pesquisa o Nro do Pedido do Progresso                       |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_PEDIDO(cPedido)
oLbIteRelP:nAt := aScan(aIteRelP,{|x| left(x[1],len(Alltrim(cPedido))) == Alltrim(cPedido) }) // Verifica se existe o Pedido Digitado
If oLbIteRelP:nAt <= 0
	MsgStop(STR0015,STR0002) // Pedido nao encontrado! / Atencao
	oLbIteRelP:nAt := 1
EndIf
FS_REFRESH()
Return()

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | FS_REFRESH | Autor | Andre Luis Almeida    | Data | 08/07/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Refresh do ListBox dos Progressos                            |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_REFRESH()
oLbIteRelP:nAt:=1 //manipulado nAt para evitar erro array
oLbIteRelP:SetArray(aIteRelP)
oLbIteRelP:bLine := { || { Transform(aIteRelP[oLbIteRelP:nAt,8],"@D") ,;
Transform(aIteRelP[oLbIteRelP:nAt,9],"@D") ,;
aIteRelP[oLbIteRelP:nAt,1],;
aIteRelP[oLbIteRelP:nAt,2],;
aIteRelP[oLbIteRelP:nAt,3],;
aIteRelP[oLbIteRelP:nAt,4],;
aIteRelP[oLbIteRelP:nAt,5],;
aIteRelP[oLbIteRelP:nAt,6],;
aIteRelP[oLbIteRelP:nAt,7] }}
oLbIteRelP:Refresh()
Return()

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | FS_VXC004  | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Retorna Codigo do Progresso para o Atendimento               |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_VXC004(lFazAss)
Local cQryAlias := "SQLVJ1"
Local cQuery := ""
Local aRet   := {}
Local cMsg   := ""
If lFazAss .and. !Empty(aIteRelP[oLbIteRelP:nAt,1])
	If !Empty(aIteRelP[oLbIteRelP:nAt,5])
		MsgStop(STR0016+" " + aIteRelP[oLbIteRelP:nAt,5]+".",STR0002) // O progresso ja esta empenhado ao atendimento / Atencao
		Return(aRet)
	EndIf
	cMsg := STR0017 +CHR(13)+CHR(10)+CHR(13)+CHR(10)+ ; // Deseja cadastrar uma VENDA FUTURA para o modelo abaixo ?
			STR0013 +": "+ AllTrim(aIteRelP[oLbIteRelP:nAt,2]) +" - "+ AllTrim(aIteRelP[oLbIteRelP:nAt,3]) +" - "+ aIteRelP[oLbIteRelP:nAt,4] +CHR(13)+CHR(10)+ ; // Modelo
			STR0008 +": "+ aIteRelP[oLbIteRelP:nAt,6] +CHR(13)+CHR(10)+ ; // Cor
			STR0009 +": "+ aIteRelP[oLbIteRelP:nAt,7] // Opcionais
	If !Empty(M->VV9_NUMATE)
		cQuery := "SELECT * FROM "+RetSqlName("VJ1")+" VJ1 WHERE VJ1.VJ1_FILIAL='"+xFilial("VJ1")+"' AND VJ1.D_E_L_E_T_=' ' AND VJ1.VJ1_NUMTRA='"+M->VV9_NUMATE+"'"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias, .F., .T. )
		If !(cQryAlias)->(Eof())
			cOpcVJ1 := Alltrim((cQryAlias)->(VJ1_OPC001)+"/"+(cQryAlias)->(VJ1_OPC002)+"/"+(cQryAlias)->(VJ1_OPC003)+"/"+(cQryAlias)->(VJ1_OPC004)+"/"+(cQryAlias)->(VJ1_OPC005);
			+"/"+(cQryAlias)->(VJ1_OPC006)+"/"+(cQryAlias)->(VJ1_OPC007)+"/"+(cQryAlias)->(VJ1_OPC008)+"/"+(cQryAlias)->(VJ1_OPC009)+"/"+(cQryAlias)->(VJ1_OPC010);
			+"/"+(cQryAlias)->(VJ1_OPC011)+"/"+(cQryAlias)->(VJ1_OPC012)+"/"+(cQryAlias)->(VJ1_OPC013)+"/"+(cQryAlias)->(VJ1_OPC014)+"/"+(cQryAlias)->(VJ1_OPC015);
			+"/"+(cQryAlias)->(VJ1_OPC016)+"/"+(cQryAlias)->(VJ1_OPC017)+"/"+(cQryAlias)->(VJ1_OPC018)+"/"+(cQryAlias)->(VJ1_OPC019)+"/"+(cQryAlias)->(VJ1_OPC020);
			+"/"+(cQryAlias)->(VJ1_OPC021)+"/"+(cQryAlias)->(VJ1_OPC022)+"/"+(cQryAlias)->(VJ1_OPC023)+"/"+(cQryAlias)->(VJ1_OPC024))
			While Right(cOpcVJ1,1)=="/" .or. Right(cOpcVJ1,1)==" "
				cOpcVJ1 := Left(cOpcVJ1,Len(cOpcVJ1)-1)
			EndDo
			cMsg := STR0018 +" "+ Alltrim((cQryAlias)->(VJ1_CODPED))+"."+CHR(13)+CHR(10)+; // O atendimento ja esta vinculado ao progresso
					STR0013 +": "+ AllTrim((cQryAlias)->(VJ1_CODMAR)) + " - " + AllTrim((cQryAlias)->(VJ1_MODVEI)) + " - " + AllTrim(Posicione("VV2",1, xFilial("VV2") + (cQryAlias)->(VJ1_CODMAR) + (cQryAlias)->(VJ1_MODVEI),"VV2_DESMOD")) +CHR(13)+CHR(10)+; // Modelo
					STR0008 +": "+ Posicione("VVC",1, xFilial("VVC") + (cQryAlias)->(VJ1_CODMAR) + STRZERO((cQryAlias)->(VJ1_COREXT),2),"VVC_DESCRI") + CHR(13)+CHR(10)+ ; // Cor
					STR0009 +": "+ cOpcVJ1 +CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Opcionais
					cMsg
		EndIf
		(cQryAlias)->(dbCloseArea())
	EndIf
	If MsgYesNo(cMsg,STR0002) // Atencao
		aRet := {aIteRelP[oLbIteRelP:nAt,2],aIteRelP[oLbIteRelP:nAt,1]} // VJ1_CODMAR / VJ1_CODPED
	EndIf
EndIf
Return(aRet)