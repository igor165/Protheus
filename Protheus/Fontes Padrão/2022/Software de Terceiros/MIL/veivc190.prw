// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 06     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Protheus.ch"
#include "veivc190.ch"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  26/09/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007398_1"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | VEIVC190   | Autor |  Luis Delorme         | Data | 21/01/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Consulta Veiculos para Transferencia                         |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VEIVC190(cProduto)
Local aObjects := {} , aInfo := {}, aPos := {}, nCntFor
Local aSizeHalf := MsAdvSize(.t.)
Local lRet := .f.
Private aRet := {}
Private oFnt1 := TFont():New( "System", , 12 )
Private oFnt2 := TFont():New( "Courier New", , 16,.t. )
Private oFnt3 := TFont():New( "Arial", , 14,.t. )
Private aIteRelP := {{"","","","","","","","","","","",""}}
Private aIteRelA := {{"","","","",0,0}}
Private aExpXLS := {}
Private aIteRelM := {}
Private oVerd := LoadBitmap( GetResources(), "BR_VERDE" )    	// Veículo Livre
Private oAzul := LoadBitmap( GetResources(), "BR_AZUL")			// Com Atendimento na propria filial
Private oVerm := LoadBitmap( GetResources(), "BR_VERMELHO")		// Com Atendimento Aprovado em Outra Filial
Private oAmar := LoadBitmap( GetResources(), "BR_AMARELO")  	// Com Atendimento em outra filial
Private cCaminho := ""
Private aNewBot := {;
{"PMSCOLOR",    {|| VC190LEG()   }, STR0002 }, ;
{"PESQUISA",    {|| VC190PERG()   }, STR0003 }, ;
{"MDIEXCEL",      {|| VC190XLS()}, STR0004 } }
//
VC190PERG()
// Fator de reducao de 0.8
//for nCntFor := 1 to Len(aSizeHalf)
//	aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.8)
//next
// ########################################################################
// # Montagem das informacoes de posicionamento da consulta               #
// ########################################################################
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 }// Tamanho total da tela
AAdd( aObjects, { 0, 04, .T., .f. } )
AAdd( aObjects, { 0, 08, .T., .T. } )
AAdd( aObjects, { 0, 100, .T., .f. } )
aPos := MsObjSize( aInfo, aObjects )
dyc := (aPos[1,4] - aPos[1,2])
dyc2 := (aPos[1,4] - aPos[1,2]) / 2	// step horizontal
_nSpc := 40
_nLarg := dyc2 - _nSpc - 10
nBtnSize := 25
// ########################################################################
// # Montagem da tela com informacoes fixas                               #
// ########################################################################
DEFINE MSDIALOG oDlgCP FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0001 OF oMainWnd PIXEL
// ########################################################################
// # Montagem da listbox contendo informacoes dos veículos                #
// ########################################################################
@ aPos[2,1],aPos[2,2] LISTBOX oLbIteRelP FIELDS HEADER ;
(STR0005), ;
(" "), ;
(STR0006), ;
(STR0007), ;
(STR0008), ;
(STR0009), ;
(STR0010), ;
(STR0011), ;
(STR0012), ;
(STR0013), ;
(STR0014), ;
(STR0015) ;
COLSIZES 0.037 * dyc, 0.037 * dyc, 0.037 * dyc, 0.074 * dyc, 0.148 * dyc, 0.074 * dyc, 0.074 * dyc, 0.148 * dyc, 0.074 * dyc, 0.074 * dyc, 0.074 * dyc, 0.148 * dyc ;
SIZE aPos[2,4] - aPos[2,2], aPos[2,3] - aPos[2,1];
OF oDlgCP ON DBLCLICK ( VC190DBCK() ) PIXEL
//
oLbIteRelP:SetArray(aIteRelP)
//
oLbIteRelP:bLine := { || { aIteRelP[oLbIteRelP:nAt,1],;
IIF(aIteRelP[oLbIteRelP:nAt,2]=="N",oVerd,IIF(aIteRelP[oLbIteRelP:nAt,2]=="L",oAzul,IIF(aIteRelP[oLbIteRelP:nAt,2]=="U",oVerm,oAmar))),;
aIteRelP[oLbIteRelP:nAt,3],;
Alltrim(aIteRelP[oLbIteRelP:nAt,4]),;
aIteRelP[oLbIteRelP:nAt,5],;
aIteRelP[oLbIteRelP:nAt,6],;
IIF(aIteRelP[oLbIteRelP:nAt,7]=="0",STR0041,STR0042),;
aIteRelP[oLbIteRelP:nAt,8],;
aIteRelP[oLbIteRelP:nAt,9],;
aIteRelP[oLbIteRelP:nAt,10],;
aIteRelP[oLbIteRelP:nAt,11],;
IIF(aIteRelP[oLbIteRelP:nAt,12]==aIteRelP[oLbIteRelP:nAt,1],"",aIteRelP[oLbIteRelP:nAt,12])}}
// ########################################################################
// # Montagem da listbox contendo informacoes dos veículos                #
// ########################################################################
@ aPos[3,1],aPos[3,2] LISTBOX oLbIteRelA FIELDS HEADER ;
(STR0005), ;
(STR0007), ;
(STR0008), ;
(STR0016), ;
(STR0017), ;
(STR0018) ;
COLSIZES 0.1 * dyc2, 0.2 * dyc2, 0.3 * dyc2, 0.1 * dyc2, 0.1 * dyc2, 0.1* dyc2 ;
SIZE aPos[3,4]/2 - aPos[3,2]/2, aPos[3,3] - aPos[3,1];
OF oDlgCP ON DBLCLICK ( oLbIteRelA:Refresh() ) PIXEL
//
oLbIteRelA:SetArray(aIteRelA)
//
oLbIteRelA:bLine := { || { aIteRelA[oLbIteRelA:nAt,1],;
aIteRelA[oLbIteRelA:nAt,2],;
aIteRelA[oLbIteRelA:nAt,3],;
FG_AlinVlrs(Transform(aIteRelA[oLbIteRelA:nAt,4],"@E 99999")),;
FG_AlinVlrs(Transform(aIteRelA[oLbIteRelA:nAt,5],"@E 99999")),;
Transform(aIteRelA[oLbIteRelA:nAt,6],"@E 999.99%")}}
//
ACTIVATE MSDIALOG oDlgCP CENTER ON INIT (EnchoiceBar(oDlgCP,{|| oDlgCP:End()},{ || oDlgCP:End() },,aNewBot ))
//
return lRet
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | VC190PERG  | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Monta ParamBox                                               |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VC190PERG()
Local nCntFor
Local nOpcGetFil := GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY
Local aParamBox := {}
Local aCombo1 := {STR0019,STR0020,STR0021}

aAdd(aParamBox,{1,STR0022,Space(2),"","","","",35,.F.})
aAdd(aParamBox,{1,STR0023,Space(2),"","","","",35,.F.})
aAdd(aParamBox,{1,STR0024,Space(2),"","","NNR","",35,.F.})
aAdd(aParamBox,{1,STR0025,Space(2),"","","NNR","",35,.F.})
aAdd(aParamBox,{1,STR0026,Space(15),"","","","",70,.F.})
aAdd(aParamBox,{1,STR0027,Space(15),"","","","",70,.F.})
aAdd(aParamBox,{1,STR0028,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data
aAdd(aParamBox,{1,STR0029,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data
aAdd(aParamBox,{2,STR0030,aCombo1[3],aCombo1,60,"",.F.})
aAdd(aParamBox,{1,STR0047,Space(100),"","MV_PAR10:=cGetFile('Arquivos |*.*','',,,,"+AllTrim(Str(nOpcGetFil))+")","","",100,.F.})
If !ParamBox(aParamBox,STR0001,@aRet)
	Return .f.
Endif

cCaminho := aRet[10]

//
// Filtra os veículos
//
if Type("aRet[09]")=="C"
	aRet[09] := Val(Left(aRet[09],1))
endif

//
lConsFil := (!Empty(aRet[02]))
lConsLoc := (!Empty(aRet[04]))
lConsLocz := (!Empty(aRet[06]))
lConsEst := (aRet[09] != 3)

cQryAlias := "SQLALIAS"

cQuery := "SELECT SB2.B2_FILIAL, "
cQuery += "       VV1.VV1_CODMAR, "
cQuery += "       VV2.VV2_MODVEI, "
cQuery += "       VV2.VV2_DESMOD, "
cQuery += "       VV1.VV1_FABMOD, "
cQuery += "       VV1.VV1_ESTVEI, "
cQuery += "       VV1.VV1_CHASSI, "
cQuery += "       VVC.VVC_DESCRI, "
cQuery += "       VV1.VV1_SITVEI,  "
cQuery += "       SB1.B1_LOCPAD,  "
cQuery += "       SB5.B5_LOCALI2  "
cQuery += "FROM  "+RetSqlName("SB2")+" SB2, "
cQuery +=          RetSqlName("VV1")+" VV1, "
cQuery +=          RetSqlName("VV2")+" VV2, "
cQuery +=          RetSqlName("VVC")+" VVC, "
cQuery +=          RetSqlName("VVF")+" VVF, "
cQuery +=          RetSqlName("VVG")+" VVG, "
cQuery +=          RetSqlName("SB1")+" SB1 "
cQuery += "LEFT OUTER JOIN "+RetSqlName("SB5")+" SB5  ON ("
if lConsLocz
	cQuery +=        "SB5.B5_LOCALI2 >= '"+aRet[05]+"' AND "
	cQuery +=        "SB5.B5_LOCALI2 <= '"+aRet[06]+"' AND "
endif
cQuery +=        "SB1.B1_COD = SB5.B5_COD AND "
cQuery +=        "SB5.B5_FILIAL = '"+xFilial("SB5")+"' AND "
cQuery +=        "SB5.D_E_L_E_T_ = ' ' ) "

cQuery += "WHERE  VVF.VVF_OPEMOV = '0' AND "
cQuery +=        "VVF.VVF_SITNFI = '1' AND "
if lConsLoc
	cQuery +=        "SB1.B1_LOCPAD >= '"+aRet[03]+"' AND "
	cQuery +=        "SB1.B1_LOCPAD <= '"+aRet[04]+"' AND "
endif
if lConsFil
	cQuery +=        "VVF.VVF_FILIAL >= '"+aRet[01]+"' AND "
	cQuery +=        "VVF.VVF_FILIAL <= '"+aRet[02]+"' AND "
endif
cQuery +=        "VVF.VVF_TRACPA = VVG.VVG_TRACPA AND "
cQuery +=        "SB1.B1_CODITE = VVG.VVG_CHAINT AND "
cQuery +=        "SB1.B1_GRUPO = '"+Alltrim(GetMV("MV_GRUVEI"))+"' AND "
cQuery +=        "VVG.VVG_CHASSI = VV1.VV1_CHASSI AND "
cQuery +=        "SB2.B2_COD = SB1.B1_COD AND "
cQuery +=        "SB2.B2_QATU = 1 AND "

cQuery +=        "VV1.VV1_MODVEI = VV2.VV2_MODVEI AND "
cQuery +=        "VV1.VV1_CODMAR = VV2.VV2_CODMAR AND "
if lConsEst
	if aRet[09] == 1
		cQuery +=        "VV1.VV1_ESTVEI = '0' AND "
	else
		cQuery +=        "VV1.VV1_ESTVEI = '1' AND "
	endif
endif
cQuery +=        "VVC.VVC_CORVEI = VV1.VV1_CORVEI AND "
cQuery +=        "VVF.VVF_FILIAL = VVG.VVG_FILIAL AND "
cQuery +=        "VVC.VVC_FILIAL = '"+xFilial("VVC")+"' AND "
cQuery +=        "VVC.VVC_CODMAR = VV1.VV1_CODMAR AND "
cQuery +=        "VV1.VV1_FILIAL = '"+xFilial("VV1")+"' AND "
cQuery +=        "VV2.VV2_FILIAL = '"+xFilial("VV2")+"' AND "
cQuery +=        "SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND "
cQuery +=        "SB1.D_E_L_E_T_ = ' ' AND "
cQuery +=        "VVG.D_E_L_E_T_ = ' ' AND "
cQuery +=        "VVF.D_E_L_E_T_ = ' ' AND "
cQuery +=        "VVC.D_E_L_E_T_ = ' ' AND "
cQuery +=        "VV2.D_E_L_E_T_ = ' ' AND "
cQuery +=        "VV1.D_E_L_E_T_ = ' ' AND "
cQuery +=        "SB2.D_E_L_E_T_ = ' ' "

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias, .F., .T. )

(cQryAlias)->(dbGoTop())
aIteRelP := {}
aExpXLS := {}
while !(cQryAlias)->(eof())
	if (cQryAlias)->(VV1_SITVEI) == "0"
		cStatus := STR0031
	elseif (cQryAlias)->(VV1_SITVEI) == "1"
		cStatus := STR0032
	elseif (cQryAlias)->(VV1_SITVEI) == "2"
		cStatus := STR0033
	elseif (cQryAlias)->(VV1_SITVEI) == "3"
		cStatus := STR0034
	elseif (cQryAlias)->(VV1_SITVEI) == "4"
		cStatus := STR0035
	elseif (cQryAlias)->(VV1_SITVEI) == "5"
		cStatus := STR0036
	else
		cStatus := STR0037
	endif
	aAdd(aIteRelP,{(cQryAlias)->(B2_FILIAL), ;  // 1
	"N", ;							// 2
	(cQryAlias)->(VV1_CODMAR), ; 				// 3
	(cQryAlias)->(VV2_MODVEI), ;		// 4
	(cQryAlias)->(VV2_DESMOD), ;		// 5
	(cQryAlias)->(VV1_FABMOD), ;		// 6
	(cQryAlias)->(VV1_ESTVEI), ;		// 7
	(cQryAlias)->(VV1_CHASSI), ;		// 8
	(cQryAlias)->(VVC_DESCRI), ;		// 9
	Alltrim((cQryAlias)->(B1_LOCPAD))+"-"+Alltrim((cQryAlias)->(B5_LOCALI2)), ;			// 10
	cStatus, ;		// 11
	(cQryAlias)->(B2_FILIAL)})					// 12
	(cQryAlias)->(DBSkip())
enddo
(cQryAlias)->(dbCloseArea())
DBSelectArea("VV2")

for nCntFor := 1 to Len(aIteRelP)
	cQuery := "SELECT VVA_FILIAL, VV9_STATUS"
	cQuery +=  " FROM "+RetSQLName("VVA")+" VVA , "+RetSQLName("VV9")+" VV9 "
	cQuery += " WHERE VVA_CHASSI = '"+aIteRelP[nCntFor,8]+"'"
	cQuery +=   " AND VVA.D_E_L_E_T_ = ' '"
	cQuery +=   " AND VV9_FILIAL = VVA_FILIAL"
	cQuery +=   " AND VV9_NUMATE = VVA_NUMTRA"
	cQuery +=   " AND VV9_STATUS NOT IN ('C','F','T','R','D')" // Considerar somente atendimento em aberto
	cQuery +=   " AND VV9.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias, .F., .T. )
	(cQryAlias)->(dbGoTop())
	if !(cQryAlias)->(eof())
		aIteRelP[nCntFor,12] := (cQryAlias)->(VVA_FILIAL)
		if aIteRelP[nCntFor,1] != (cQryAlias)->(VVA_FILIAL)
			if (cQryAlias)->(VV9_STATUS) == "L"
				aIteRelP[nCntFor,2] := "U"
			elseif (cQryAlias)->(VV9_STATUS) == "A"
				aIteRelP[nCntFor,2] := "R"
			endif
		else
			aIteRelP[nCntFor,2] := "L"
		endif
	endif
	(cQryAlias)->(dbCloseArea())
	DBSelectArea("VV2")
	if aIteRelP[nCntFor,1] != aIteRelP[nCntFor,12]
		aAdd(aExpXLS,{aIteRelP[nCntFor,1],;
		Alltrim(aIteRelP[nCntFor,4])+"-"+Alltrim(aIteRelP[nCntFor,5]),;
		aIteRelP[nCntFor,9],;
		aIteRelP[nCntFor,8],;
		aIteRelP[nCntFor,12],;
		iif(aIteRelP[nCntFor,2] == "N",STR0038,iif(aIteRelP[nCntFor,2] == "R", STR0039,STR0040))})
	endif
next
//
if Empty(aIteRelP)
	aIteRelP := {{"","","","","","","","","","","",""}}
endif
//
VC190MOD()
//
if Type("oLbIteRelP") != "U"
	oLbIteRelP:SetArray(aIteRelP)
	oLbIteRelP:bLine := { || { aIteRelP[oLbIteRelP:nAt,1],;
	IIF(aIteRelP[oLbIteRelP:nAt,2]=="N",oVerd,IIF(aIteRelP[oLbIteRelP:nAt,2]=="L",oAzul,IIF(aIteRelP[oLbIteRelP:nAt,2]=="U",oVerm,oAmar))),;
	aIteRelP[oLbIteRelP:nAt,3],;
	aIteRelP[oLbIteRelP:nAt,4],;
	aIteRelP[oLbIteRelP:nAt,5],;
	aIteRelP[oLbIteRelP:nAt,6],;
	IIF(aIteRelP[oLbIteRelP:nAt,7]=="0","NOVO","USADO"),;
	aIteRelP[oLbIteRelP:nAt,8],;
	aIteRelP[oLbIteRelP:nAt,9],;
	aIteRelP[oLbIteRelP:nAt,10],;
	aIteRelP[oLbIteRelP:nAt,11],;
	IIF(aIteRelP[oLbIteRelP:nAt,12]==aIteRelP[oLbIteRelP:nAt,1],"",aIteRelP[oLbIteRelP:nAt,12])}}
	oLbIteRelP:Refresh()
endif
//
return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | VC190DBCK  | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Trata duplo click na janela                                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VC190DBCK()

Local nCntFor
aIteRelA := {}
cMarca := aIteRelP[oLbIteRelP:nAt,3]
cModelo := aIteRelP[oLbIteRelP:nAt,4]
DBSelectArea("VV2")
DBSetOrder(1)
DBSeek(xFilial("VV2")+cMarca + cModelo)

For nCntFor := 1 to Len(aIteRelM)
	if aIteRelM[nCntFor,2] == cModelo
		aAdd(aIteRelA,{aIteRelM[nCntFor,1],aIteRelM[nCntFor,2] , VV2->VV2_DESMOD, aIteRelM[nCntFor,4], aIteRelM[nCntFor,5], aIteRelM[nCntFor,6]})
	endif
next
if Empty(aIteRelA)
	aIteRelA := {{"","","","",0,0}}
endif
//
oLbIteRelA:SetArray(aIteRelA)
//
oLbIteRelA:bLine := { || { aIteRelA[oLbIteRelA:nAt,1],;
aIteRelA[oLbIteRelA:nAt,2],;
aIteRelA[oLbIteRelA:nAt,3],;
FG_AlinVlrs(Transform(aIteRelA[oLbIteRelA:nAt,4],"@E 99999")),;
FG_AlinVlrs(Transform(aIteRelA[oLbIteRelA:nAt,5],"@E 99999")),;
FG_AlinVlrs(Transform(aIteRelA[oLbIteRelA:nAt,6],"@E 999.99%"))}}
oLbIteRelA:Refresh()
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | VC190XLS   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Exporta Informações para Planilha                            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VC190XLS()
Local cNome    := "VEIVC190"
Local cNomeArq := cCaminho+"VEIVC190.xls"
Local nCntFor
Local oExcel   := FWMSEXCEL():New()
oExcel:AddWorkSheet(cNome)
oExcel:AddTable(cNome,STR0001) // Nome / Titulo

oExcel:AddColumn( cNome , STR0001 , STR0043 , 1 , 1 ) // Unidade
oExcel:AddColumn( cNome , STR0001 , STR0007 , 1 , 1 ) // Modelo 
oExcel:AddColumn( cNome , STR0001 , STR0012 , 1 , 1 ) // Cor
oExcel:AddColumn( cNome , STR0001 , STR0011 , 1 , 1 ) // Chassi  
oExcel:AddColumn( cNome , STR0001 , STR0047 , 1 , 1 ) // Destino
oExcel:AddColumn( cNome , STR0001 , STR0048 , 1 , 1 ) // Observacao
oExcel:AddColumn( cNome , STR0001 , STR0049 , 1 , 1 ) // Transp

for nCntFor := 1 to Len(aExpXLS)
	oExcel:AddRow( cNome , STR0001 , ;
				{ 	aExpXLS[nCntFor,1] ,;
		            aExpXLS[nCntFor,2] ,;
		            aExpXLS[nCntFor,3] ,;
		            aExpXLS[nCntFor,4] ,;
		            aExpXLS[nCntFor,5] ,;
		            aExpXLS[nCntFor,6] ,;
	            	space(30);
		   		})
next


oExcel:Activate()
oExcel:GetXMLFile(cNomeArq)
oExcel:DeActivate()

MsgInfo( STR0001  + CHR(13)+CHR(10)+CHR(13)+CHR(10) + cNomeArq , STR0004 )

Return


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | VC190MOD   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Calcula valores da janela inferior                           |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VC190MOD()

Local nCntFor

dDataIni := aRet[07] // stod(STRZERO(Year(dDataFim),4)+STRZERO(Month(dDataFim),2)+"01") - 1
dDataFim := aRet[08] // stod(STRZERO(Year(DDATABASE),4)+STRZERO(Month(dDatabase),2)+"01") - 1
cQryAlias := "SQLALIAS"
cQuery := "SELECT VV0.VV0_FILIAL, VV1.VV1_CHASSI, VV1.VV1_MODVEI "
cQuery += "FROM  "+RetSqlName("VV0")+" VV0, "
cQuery +=          RetSqlName("VV1")+" VV1, "
cQuery +=          RetSqlName("VVA")+" VVA "
cQuery += "WHERE  VV0.VV0_DATEMI >= '"+DTOS(dDataIni)+"' AND "
cQuery +=        "VV0.VV0_DATEMI <= '"+DTOS(dDataFim)+"' AND "
cQuery +=        "VV0.VV0_OPEMOV = '0' AND "
cQuery +=        "VV0.VV0_SITNFI = '1' AND "
cQuery +=        "VV0.VV0_NUMTRA = VVA.VVA_NUMTRA AND "
cQuery +=        "VVA.VVA_CHASSI = VV1.VV1_CHASSI AND "
cQuery +=        "VVA.VVA_FILIAL = VV0.VV0_FILIAL AND "
cQuery +=        "VVA.D_E_L_E_T_ = ' ' AND "
cQuery +=        "VV1.D_E_L_E_T_ = ' ' AND "
cQuery +=        "VV0.D_E_L_E_T_ = ' ' "
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias, .F., .T. )
//
(cQryAlias)->(dbGoTop())
aIteRelM := {}
while !(cQryAlias)->(eof())
	nPosFil := aScan(aIteRelM,{|x| x[1]+x[2] == (cQryAlias)->(VV0_FILIAL)+(cQryAlias)->(VV1_MODVEI)})
	if nPosFil > 0
		aIteRelM[nPosFil,4] ++
	else
		DBSelectArea("VV2")
		DBSetOrder(1)
		DBSeek(xFilial("VV2")+(cQryAlias)->(VV1_MODVEI))
		aAdd(aIteRelM,{(cQryAlias)->(VV0_FILIAL), (cQryAlias)->(VV1_MODVEI) , Alltrim(VV2->VV2_DESMOD), 1, 0, 0})
		nPosFil := Len(aIteRelM)
	endif
	cQryAlias2 := "SQLALIAS2"
	cQuery2 := "SELECT COUNT(VVF.VVF_TRACPA)  CONTAGEM "
	cQuery2 += "FROM  "+RetSqlName("VVF")+" VVF, "
	cQuery2 +=          RetSqlName("VVG")+" VVG "
	cQuery2 += "WHERE VVG.VVG_CHASSI = '"+(cQryAlias)->(VV1_CHASSI)+"' AND "
	cQuery2 +=        "VVF.VVF_TRACPA = VVG.VVG_TRACPA AND "
	cQuery2 +=        "VVF.VVF_FILIAL = VVG.VVG_FILIAL AND "
	cQuery2 +=        "VVF.VVF_OPEMOV = '3' AND "
	cQuery2 +=        "VVF.VVF_SITNFI = '1' AND "
	cQuery2 +=        "VVG.D_E_L_E_T_ = ' ' AND "
	cQuery2 +=        "VVF.D_E_L_E_T_ = ' ' "
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery2 ), cQryAlias2, .F., .T. )
	
	if (cQryAlias2)->(CONTAGEM) > 0
		aIteRelM[nPosFil,5] ++
	endif
	(cQryAlias2)->(dbCloseArea())
	DBSelectArea("VV2")
	(cQryAlias)->(dbskip())
enddo

for nCntFor := 1 to Len(aIteRelM)
	aIteRelM[nCntFor,5] = aIteRelM[nCntFor,4] - aIteRelM[nCntFor,5]
	aIteRelM[nCntFor,6] = 100 * aIteRelM[nCntFor,5] / aIteRelM[nCntFor,4]
next

if Empty(aIteRelM)
	aIteRelM := {{"","","","",0,0}}
endif
//
aSort(aIteRelM,,,{|x, y| x[1] < y[1] } )
//
(cQryAlias)->(dbCloseArea())
DBSelectArea("VV2")
//
cModelo := aIteRelM[1,2]
nMenor :=  1
nMaior := 1
for nCntFor := 1 to Len(aIteRelM)
	if aIteRelM[1,2] == cModelo
		if aIteRelM[nCntFor,4] < aIteRelM[nMenor,4]
			nMenor := nCntFor
		elseif aIteRelM[nCntFor,4] > aIteRelM[nMaior,4]
			nMaior := nCntFor
		endif
	else
		nPos := aScan(aIteRelP,{|x| x[1]+x[2]+x[4]  == aIteRelM[nMenor,1]+"N"+aIteRelM[nMenor,2]})
		nPos2 := aScan(aIteRelP,{|x| x[1]+x[2]+x[4] == aIteRelM[nMaior,1]+"N"+aIteRelM[nMaior,2]})
		if nPos2 < 1 .and. nPos > 0
			aIteRelP[nPos,12] := aIteRelM[nMaior,1]
		endif
		cModelo := aIteRelM[1,2]
		nMenor :=  nCntFor
		nMaior := nCntFor
	endif
next

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA011LEG ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VC190LEG()
Local aLegenda := {;
{'BR_VERDE',STR0051},;						// "Orcamento Digitado"
{'BR_AZUL',STR0052},;				// "Aguardando Separacao"
{'BR_AMARELO',STR0053},;				// "Cancelado"
{'BR_VERMELHO',STR0054}}		// "Liberado p/ Faturamento"
//
BrwLegenda(STR0001,STR0002,aLegenda)
//
Return