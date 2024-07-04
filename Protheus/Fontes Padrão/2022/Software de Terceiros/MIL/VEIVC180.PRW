#include "Protheus.ch"
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | VEIVC180   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Consulta Progresso de Veiculos                               |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
Private aNewBot    := { {"FILTRO",{|| FILVEI011() },STR0002}, {"MAQFOTO",{|| FS_FOTO011() },STR0003}, {"FILTRO",{|| VEIVC180() },"Progresso"} } //Filtro - Foto
*/
Function VEIVC180(cCodMar, cModVei,lFazAss)
Local aObjects := {}, aInfo := {}, aPos := {}, nCntFor
Local aSizeHalf := MsAdvSize(.t.)
Local lRet := .f.
Local cQryAlias
Private oFnt1 := TFont():New( "System", , 12 )
Private oFnt2 := TFont():New( "Courier New", , 16,.t. )
Private oFnt3 := TFont():New( "Arial", , 14,.t. )
Private aIteRelP := {{"","","","","","","",""}}
Default lFazAss := .f.
cCodMar := Left(cCodMar+SPACE(10),TamSX3("VVC_CODMAR")[1])
if Empty(cCodMar) .or. Empty(cModVei)
	cCodMar := M->VV0_CODMAR
	cModVei := M->VV0_MODVEI
	if Empty(cCodMar) .or. Empty(cModVei)
		MsgInfo("Marca e Modelo não preenchidos.")
		return
	endif
endif
// ########################################################################
// # Montagem das informacoes de posicionamento da consulta               #
// ########################################################################
for nCntFor := 1 to Len(aSizeHalf)
	aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.8)
next
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 }// Tamanho total da tela
AAdd( aObjects, { 0, 0, .T., .T. } )
aPos := MsObjSize( aInfo, aObjects )
dyc := (aPos[1,4] - aPos[1,2])
// ########################################################################
// # Montagem da listbox contendo informacoes dos itens relacionados      #
// ########################################################################
cMarVj1 := cCodMar
cModVj1 := cModVei
cQryAlias := GetNextAlias()
cQuery := "SELECT * FROM "+RetSqlName("VJ1")+" WHERE VJ1_FILIAL ='"+xFilial("VJ1")+"' AND D_E_L_E_T_=' ' AND VJ1_MODVEI = '"+cModVj1+"'AND VJ1_CODMAR = '"+cMarVj1+"' AND VJ1_NUMNFI = '000000' AND VJ1_NUMTRA = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias, .F., .T. )
(cQryAlias)->(dbGoTop())
aIteRelP := {}
while !(cQryAlias)->(eof())
	DBSelectArea("VV2")
	DBSetOrder(1)
	DBSeek(xFilial("VV2")+cMarVj1+cModVj1)
	aIteP := {}
	aAdd(aIteP,(cQryAlias)->(VJ1_CODPED))
	aAdd(aIteP,(cQryAlias)->(VJ1_CODMAR))
	aAdd(aIteP,(cQryAlias)->(VJ1_MODVEI))
	aAdd(aIteP,VV2->VV2_DESMOD)
	aAdd(aIteP,(cQryAlias)->(VJ1_NUMTRA))
	DBSelectArea("VVC")
	DBSetOrder(1)
	if DBSeek(xFilial("VVC")+cMarVj1+STRZERO(VJ1->VJ1_COREXT,2))
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
	aAdd(aIteP,stod((cQryAlias)->(VJ1_DATPRO)))
	aAdd(aIteRelP,aIteP)
	(cQryAlias)->(DBSkip())
enddo
(cQryAlias)->(dbCloseArea())
//
if Empty(aIteRelP)
	aIteRelP := {{"","","","","","","",""}}
endif


DEFINE MSDIALOG oDlgCP FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE "Consulta de Progressos" OF oMainWnd PIXEL

@ aPos[1,1],aPos[1,2] LISTBOX oLbIteRelP FIELDS HEADER ;
OemToAnsi("Pedido"),;
OemToAnsi("Marca"), ;
OemToAnsi("Modelo"), ;
OemToAnsi("Descricao"), ;
OemToAnsi("Empenhado"), ;
OemToAnsi("Cor"), ;
OemToAnsi("Acessorios"), ;
OemToAnsi("Prev.Ent.") ;
COLSIZES 0.05 * dyc, 0.05 * dyc, 0.10 * dyc, 0.25 * dyc, 0.05 * dyc, 0.15 * dyc, 0.25 * dyc , 0.10 * dyc  ;
SIZE aPos[1,4] - aPos[1,2], aPos[1,3] - aPos[1,1];
OF oDlgCP ON DBLCLICK ( VC180DBLC(lFazAss),oDlgCP:End() ) PIXEL
//
oLbIteRelP:SetArray(aIteRelP)
//
oLbIteRelP:bLine := { || { aIteRelP[oLbIteRelP:nAt,1],;
aIteRelP[oLbIteRelP:nAt,2],;
aIteRelP[oLbIteRelP:nAt,3],;
aIteRelP[oLbIteRelP:nAt,4],;
aIteRelP[oLbIteRelP:nAt,5],;
aIteRelP[oLbIteRelP:nAt,6],;
aIteRelP[oLbIteRelP:nAt,7],;
Transform(aIteRelP[oLbIteRelP:nAt,8],"@D") } }
// ########################################################################
// # Verifica se houve passagem de parametro contendo algum codigo (SB1)  #
// ########################################################################
ACTIVATE MSDIALOG oDlgCP CENTER ON INIT (EnchoiceBar(oDlgCP,{|| oDlgCP:End()},{ || oDlgCP:End()},,))
//
return lRet

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | VEIVC180   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Consulta Pecas de Orcamento                                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VC180DBLC(lFazAss)
Local nCntFor
Local cQryAlias

if !Empty(aIteRelP[oLbIteRelP:nAt,5])
	MsgInfo("O progresso ja esta empenhado ao atendimento " + aIteRelP[oLbIteRelP:nAt,5])
	return
endif

cQryAlias := GetNextAlias()
cQuery := "SELECT * FROM "+RetSqlName("VJ1")+" WHERE VJ1_FILIAL ='"+xFilial("VJ1")+"' AND D_E_L_E_T_=' ' AND VJ1_NUMTRA = '"+M->VV0_NUMTRA+"'"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias, .F., .T. )

if lFazAss
	if !(cQryAlias)->(eof())
		MsgInfo("O atendimento ja esta vinculado ao progresso " +Alltrim((cQryAlias)->(VJ1_CODPED))+".")
		(cQryAlias)->(dbCloseArea())
		return
	endif
	cOpc :=""
	for nCntFor := 1 to 24
		if ! Empty(&("VJ1->VJ1_OPC"+STRZERO(nCntFor,3)))
			cOpc += &("VJ1->VJ1_OPC"+STRZERO(nCntFor,3))+"/"
		endif
	next
	BEGIN TRANSACTION	
	DBSelectArea("VJ1")
	DBSetOrder(1)
	DBSeek(xFilial("VJ1")+aIteRelP[oLbIteRelP:nAt,2]+aIteRelP[oLbIteRelP:nAt,1])
	reclock("VJ1",.f.)
	VJ1->VJ1_NUMTRA := M->VV0_NUMTRA
	msunlock()
	DBSelectArea("VV1")
	DBSetOrder(1)
	if !DBSeek(xFilial("VV1")+VJ1->VJ1_CHAINT)
		INCLUI := .t.
		xAutoVeic := {}
		aAdd(xAutoVeic,{"VV1_FILIAL"  ,xFilial("VV1")   ,Nil})
		aAdd(xAutoVeic,{"VV1_STATUS"  ,xFilial("SD2")   ,Nil})  // <---- ATUALIZAR
		aAdd(xAutoVeic,{"VV1_CODMAR"  ,cCodMar   		,Nil})
		aAdd(xAutoVeic,{"VV1_LOCPAD"  ,"01"		   		,Nil})
		aAdd(xAutoVeic,{"VV1_CHAINT"  ,VJ1->VJ1_CHAINT	,Nil})
		aAdd(xAutoVeic,{"VV1_MODVEI"  ,VJ1->VJ1_MODVEI  ,Nil})
		aAdd(xAutoVeic,{"VV1_PEDFAB"  ,VJ1->VJ1_CODPED	,Nil})
		aAdd(xAutoVeic,{"VV1_CHASSI"  ,VJ1->VJ1_CHASSI  ,Nil})
		aAdd(xAutoVeic,{"VV1_TIPCAB"  ,VJ1->VJ1_CABINA  ,Nil})
		aAdd(xAutoVeic,{"VV1_CAMBIO"  ,VJ1->VJ1_CAMBIO  ,Nil})
		aAdd(xAutoVeic,{"VV1_NUMDIF"  ,VJ1->VJ1_DIFERE  ,Nil})
		aAdd(xAutoVeic,{"VV1_NUMTRA"  ,VJ1->VJ1_NUMTRA  ,Nil})
		aAdd(xAutoVeic,{"VV1_NUMMOT"  ,VJ1->VJ1_MOTOR   ,Nil})
		aAdd(xAutoVeic,{"VV1_CORVEI"  ,STRZERO(VJ1->VJ1_CORINT,2)   ,Nil})
		aAdd(xAutoVeic,{"VV1_CORFXA"  ,STRZERO(VJ1->VJ1_COREXT,2)   ,Nil})
		aAdd(xAutoVeic,{"VV1_OPCFAB"  ,cOpc   ,Nil})
		aAdd(xAutoVeic,{"VV1_PROVEI","1"   ,Nil})
		aAdd(xAutoVeic,{"VV1_INDCAL","0"   ,Nil})
		aAdd(xAutoVeic,{"VV1_RESERV","0"	   ,Nil})
		aAdd(xAutoVeic,{"VV1_SITVEI","2"   ,Nil})
		aAdd(xAutoVeic,{"VV1_ESTVEI"  ,"0"   ,Nil})
		aAdd(xAutoVeic,{"VV1_CODORI"  ,"0"   ,Nil})
		//
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("VV1")
		While !EOF() .And. (X3_ARQUIVO == "VV1")
			if X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
				If aScan(xAutoVeic,{|x| x[1] == x3_campo}) == 0
					aAdd(xAutoVeic,{x3_campo  ,CriaVar(x3_campo)   ,Nil})
				Endif
			EndIF
			DbSkip()
		EndDO
		//
		aAutoVeic  := VV1->(MSArrayXDB(xAutoVeic))
		//
		DBSelectArea("VV1")
		
		RecLock("VV1",.t.)
		For nCntfor := 1 to Len(aAutoVeic)
			if !Empty(aAutoVeic[nCntfor,2])
				&("VV1->"+aAutoVeic[nCntfor,1]) := aAutoVeic[nCntfor,2]
			endif
		Next
		MsUnlock()
		//
		cCodSB1 := Left(GetMv("MV_GRUVEI")+Space(10),Len(SB1->B1_GRUPO))+"_"+VJ1->VJ1_CHAINT
		//
		aIncSB1 := {}
		aAdd(aIncSB1,{"B1_FILIAL"  ,xFilial("SB1")    	,Nil})
		aAdd(aIncSB1,{"B1_COD"     ,cCodSB1           	,Nil})
		aAdd(aIncSB1,{"B1_CODITE"  ,VV1->VV1_CHAINT   	,Nil})
		aAdd(aIncSB1,{"B1_DESC"    ,"PROGRESSO_"+VV1->VV1_CHAINT   	,Nil})
		aAdd(aIncSB1,{"B1_TIPO"    ,GetMv("MV_TIPVEI")	,Nil})
		aAdd(aIncSB1,{"B1_UM"      ,"UN"              	,Nil})
		aAdd(aIncSB1,{"B1_LOCPAD"  ,"01"   				,Nil}) // << tem lugar melhor ? TODO
		//		aAdd(aIncSB1,{"B1_PICM"    ,VIV->VIV_ALICMS    	,Nil})
		//		aAdd(aIncSB1,{"B1_IPI"     ,VIV->VIV_ALIPI   	,Nil})
		aAdd(aIncSB1,{"B1_PESO"    ,1                  	,Nil})
		aAdd(aIncSB1,{"B1_TIPOCQ"  ,"M"                	,Nil})
		aAdd(aIncSB1,{"B1_CONTRAT" ,"N"                	,Nil})
		aAdd(aIncSB1,{"B1_LOCALIZ" ,"N"                	,Nil})
		aAdd(aIncSB1,{"B1_CODBAR"  ,VV1->VV1_CHAINT    	,Nil})
		//		aAdd(aIncSB1,{"B1_ORIGEM"  ,VVG->VVG_SITTRI    	,Nil})
		aAdd(aIncSB1,{"B1_IRRF"    ,"N"                	,Nil})
		aAdd(aIncSB1,{"B1_CONTSOC" ,"N"                	,Nil})
		aAdd(aIncSB1,{"B1_MRP"     ,"N"                	,Nil})
		aAdd(aIncSB1,{"B1_GRUPO"   ,GetMv("MV_GRUVEI") 	,Nil})
		aAdd(aIncSB1,{"B1_GRTRIB"  ,VV1->VV1_GRTRIB    	,Nil})
		aAdd(aIncSB1,{"B1_POSIPI " ,VV1->VV1_POSIPI 	,Nil})
		if GetNewPar("MV_MARGSOL",0) > 0
			aAdd(aIncSB1,{"B1_PICMENT"  ,GetNewPar("MV_MARGSOL",0) ,Nil})
		Endif
		lMsErroAuto := .f.
		MSExecAuto({|x| mata010(x)},aIncSB1)  // ??? Como Fazer alteracao
		if lMsErroAuto
			MostraErro()
			Help(" ",1,"ERROCADPRO") // Erro no Cadastro do Veiculo
			DisarmTransaction()
		Endif
		
	endif
	END TRANSACTION	
endif
(cQryAlias)->(dbCloseArea())
return
