#include "ubac005.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"
#include "fwbrowse.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} UBAC005
Consulta Beneficiamento
@author Aécio Ferreira Gomes
@since 24/07/2013   REFEITO EM 03/09/2014 - Inácio Luiz Kolling
@version MP11.8
/*/
//-------------------------------------------------------------------
Function UBAC005()
	Local oSize			:= Nil
	Local aCoors		:= FWGetDialogSize( oMainWnd )
	Private nQtdReg		:= 0
	Private aTotais 	:= {0,0,0,0,0}
	Private cNoT1,cAlT1,cNoT2,cAlT2,cNoT3,cAlT3,cNoT4,cAlT4
	Private cNoT21,cAlT21,cNoT22,cAlT22,cNoT23,cAlT23
	Private aAlT1,aAlT2,aAlT3,aAlT4
	Private aArqTRBP1	:= {}
	Private aArqTRBP2	:= {}
	Private aArqTRBP3	:= {}
	Private aArqTRBP4	:= {}
	Private cAlias1
	Private bKeyF12	  	:= {|| IIf( Pergunte("UBAC005", .T.), Processa({|| (CRIATRBS(), oDlg:Refresh())},STR0033), .T. ) }
	Private aMatArq		:= {},oDlg,oBrwP1
	Private aMatCam  	:=   {}
	Private aSize := MsAdvSize(,.f.,470)
	Private aObjects := {}
	
	SetKey( VK_F12, bKeyF12)
	
	If !IsInCallStack("OGC140") .AND. !Pergunte("UBAC005",.T.)
		Return
	EndIf

	Aadd(aObjects,{300,300,.t.,.f.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)

	aMatCam  	:=   {	{"DXL_PSESTI",TamSx3("DXL_PSESTI")[3],TamSx3("DXL_PSESTI")[1],TamSx3("DXL_PSESTI")[2],STR0009,"@E 99,999,999,999"},;
								{"DXM_PSBRUT",TamSx3("DXM_PSBRUT")[3],TamSx3("DXM_PSBRUT")[1],TamSx3("DXM_PSBRUT")[2],STR0010,"@E 99,999,999,999.99"},;
								{"DXM_PSFISC",TamSx3("DXM_PSFISC")[3],TamSx3("DXM_PSFISC")[1],TamSx3("DXM_PSFISC")[2],STR0011,"@E 99,999,999,999"},;
								{"DXQ_PSBRUT",TamSx3("DXQ_PSBRUT")[3],TamSx3("DXQ_PSBRUT")[1],TamSx3("DXQ_PSBRUT")[2],STR0012,"@E 99,999,999,999.99"},;
								{"DXL_RDMTO",TamSx3("DXL_RDMTO")[3],TamSx3("DXL_RDMTO")[1],TamSx3("DXL_RDMTO")[2],STR0013,"@E 99,999,999,999.99"}}
	

	//*Cria os arquivos temporários
	vVet1 := {{"NJ0_CODENT"},{"NJ0_NOME"},{"DXL_FAZ"},{"NN2_NOME"},{"DXI_DATA"},{"DXI_CODTUR"},{"DXM_PSLONA"},;
			  {"DXS_PSLIQU"},{"DXS_PSSUBT"},{"TOTPSFARDI","N",10,2,"INACIO","@E 99,999,999,999.99"},{"DXL_RDMTO"},{"DXI_COSTEL"},{"DXL_CODIGO"}}

	vRet1 := AGRCRIATRB(,vVet1,{"DXL_FAZ+NJ0_CODENT+DXI_DATA+DXI_CODTUR"},"UBAC005",.T.)
	cNoT1 := vRet1[3]
	cAlT1 := vRet1[4]
	aAlT1 := vRet1[5]

	vVet2 := {{"NJ0_CODENT"},{"NJ0_LOJENT"},{"DXL_FAZ"},{"DXM_PLACA"},{"DXM_DTEMIS"},{"DXL_CODIGO"},{"DXM_NOTA"},;
			  {"DXL_TALHAO"},{"DXS_PSSUBT"},{"DXM_PSLIQU"},{"DXL_RDMTO"},{"DXI_CODTUR"},{"DXI_DATA"},{"DXI_FARDAO"}}

	vRet2 := AGRCRIATRB(,vVet2,{"DXL_FAZ+NJ0_CODENT+DXI_DATA+DXI_CODTUR+DXI_FARDAO"},"UBAC005",.T.)
	cNoT2 := vRet2[3]
	cAlT2 := vRet2[4]
	aAlT2 := vRet2[5]

	vVet3 := {{"DXI_CODIGO"},{"DXI_PSLIQU"},{"DXI_PRENSA"},{"DXI_COSTEL"},{"NJ0_CODENT"},{"NJ0_LOJENT"},;
			  {"DXL_FAZ"},{"DXM_DTEMIS"},{"DXI_CODTUR"},{"DXI_FARDAO"},{"DXI_PSBRUT"}}

	vRet3 := AGRCRIATRB(,vVet3,{"DXL_FAZ+NJ0_CODENT+DXI_FARDAO+DXI_CODIGO"},"UBAC005",.T.)
	cNoT3 := vRet3[3]
	cAlT3 := vRet3[4]
	aAlT3 := vRet3[5]

	vVet4 := {{"DXI_PRENSA"},{"DXS_PSLIQU"},{"DXL_RDMTO"},{"DXM_PSLONA"},{"NJ0_CODENT"},{"NJ0_LOJENT"},{"DXL_FAZ"},;
			  {"DXI_CODIGO"},{"DXI_FARDAO"}}

	vRet4 := AGRCRIATRB(,vVet4,{"DXL_FAZ+NJ0_CODENT+DXI_FARDAO"},"UBAC005",.T.)
	cNoT4 := vRet4[3]
	cAlT4 := vRet4[4]
	aAlT4 := vRet4[5]

	//*Cria os arquivos para as grids 21,22,23
	vRet21 := AGRCRIATRB(,vVet2,{"DXL_FAZ+DXL_CODIGO"},"UBAC005",.T.)
	cNoT21 := vRet21[3]
	cAlT21 := vRet21[4]

	vRet22 := AGRCRIATRB(,vVet3,{"DXL_FAZ+NJ0_CODENT+DXI_CODIGO"},"UBAC005",.T.)
	cNoT22 := vRet22[3]
	cAlT22 := vRet22[4]

	vRet23 := AGRCRIATRB(,vVet4,{"DXL_FAZ+NJ0_CODENT+DXI_FARDAO+DXI_PRENSA"},"UBAC005",.T.)
	cNoT23 := vRet23[3]
	cAlT23 := vRet23[4]
	aMatArq := {{cAlT1,cNoT1},{cAlT2,cNoT2},{cAlT3,cNoT3},{cAlT4,cNoT4},{cAlT21,cNoT21},{cAlT22,cNoT22},{cAlT23,cNoT23}}

	//*Cria os arquivos temporários
	Processa({|| CRIATRBS()},STR0033)
	ARGSETIFARQUI(cAlT1)

	//- Coordenadas da area total da Dialog
	oSize := FWDefSize():New(.F.)
	oSize:AddObject('ALL',100,100,.T.,.T.)
	oSize:SetWindowSize(aCoors)
	oSize:aMargins := {3,3,3,3}
	oSize:lProp 	:= .T.
	oSize:Process()

	oDlg := TDialog():New(oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],oSize:aWindSize[4],STR0001,,,,,CLR_BLACK,CLR_WHITE,,,.t.) //"Benificismento"

	aTitles := {STR0001,STR0002} //"Beneficiamento","Cargas x Fardos"
	aPages  := {STR0003,STR0004} //"ESQUERDA","DIREITA"
	oFolder := TFolder():New(oSize:aPosObj[1,1], oSize:aPosObj[1,2],aTitles,aPages,oDlg,,,,.T.,,oSize:aPosObj[1,4], oSize:aPosObj[1,3]-20)
	oFolder:bchange := {|| fAtuFolder(oFolder:nOption) }

	// Instancia o layer
	oFWL1 := FWLayer():New()

	// Inicia o Layer
	oFWL1:init( oFolder:aDialogs[1],.F.)

	// Cria uma linha unica para o Layer
	oFWL1:addLine( 'SUP', 90 , .F.)
	oFWL1:addLine( 'INF', 10 , .F.)

	// Cria colunas
	oFWL1:addCollumn('ESQ',100,.T.,'INF' )
	oPnlLine1 := oFWL1:getLinePanel('SUP')
	oPnDir    := oFWL1:getColPanel('ESQ','INF')

	//-------------------------------------------------------------------
	// Define o Browse Beneficiamento
	//-------------------------------------------------------------------
	DEFINE FWFORMBROWSE oBrwP1 DATA TABLE ALIAS cAlT1 DESCRIPTION STR0001 OF oPnlLine1 //oFolder:aDialogs[1] //"Beneficiamento"
	oBrwP1:DisableDetails()
	oBrwP1:SetTemporary(.T.)
	oBrwP1:SetFieldFilter(@aArqTRBP1)
	oBrwP1:SetdbFFilter(.T.)
	oBrwP1:SetUseFilter(.T.)
	oBrwP1:BVLDEXECFILTER := {|| UBAC005RT()}
	oBrwP1:AddButton(STR0047,{||oDlg:End()},,,,,,'10')
	ADD COLUMN oColumn DATA { || &(aArqTRBP1[2,1]) } TITLE STR0005 SIZE  aArqTRBP1[1,1] ;
		PICTURE PesqPict("NJ0","NJ0_NOME") 	TYPE TamSX3("NJ0_NOME")[3]		OF oBrwP1 //"Produtor"
	ADD COLUMN oColumn DATA { || &(aArqTRBP1[4,1]) } TITLE STR0006 SIZE  aArqTRBP1[2,1] ;
		PICTURE PesqPict("NN2","NN2_NOME") 	TYPE TamSX3("NN2_NOME")[3]		OF oBrwP1 //"Fazenda"
	ADD COLUMN oColumn DATA { || &(aArqTRBP1[5,1]) } TITLE STR0007 SIZE  aArqTRBP1[3,1] ;
		PICTURE PesqPict("DXI","DXI_DATA") 	TYPE TamSX3("DXI_DATA")[3]		OF oBrwP1 //"Data Benef."
	ADD COLUMN oColumn DATA { || &(aArqTRBP1[6,1]) } TITLE STR0008	SIZE  aArqTRBP1[4,1] ;
		PICTURE PesqPict("DXI","DXI_CODTUR") 	TYPE TamSX3("DXI_CODTUR")[3]	OF oBrwP1 //"Turno"
	ADD COLUMN oColumn DATA { || &(aArqTRBP1[7,1]) } TITLE STR0009 SIZE  aArqTRBP1[5,1] ;
		PICTURE "@E 9,999,999" 					TYPE "N"							OF oBrwP1 //"Total Fardoes"
	ADD COLUMN oColumn DATA { || &(aArqTRBP1[8,1]) } TITLE STR0010 SIZE  aArqTRBP1[6,1] ;
		PICTURE PesqPict("DXL","DXL_PSLIQU")	TYPE TamSX3("DXL_PSLIQU")[3]	OF oBrwP1 //"Peso Fardoes"
	ADD COLUMN oColumn DATA { || &(aArqTRBP1[9,1]) } TITLE STR0011	SIZE  aArqTRBP1[7,1] ;
		PICTURE "@E 9,999,999" 					TYPE "N"							OF oBrwP1 //"Total Fardos"
	ADD COLUMN oColumn DATA { || &(aArqTRBP1[10,1])} TITLE STR0012	SIZE  aArqTRBP1[8,1] ;
		PICTURE PesqPict("DXL","DXL_PSLIQU")	TYPE TamSX3("DXL_PSLIQU")[3]	OF oBrwP1 //"Peso Fardos"
	ADD COLUMN oColumn DATA { || ( &(aArqTRBP1[10,1])/ &(aArqTRBP1[8,1])) * 100 }TITLE STR0013	SIZE  aArqTRBP1[9,1] ;
		PICTURE PesqPict("DXL","DXL_RDMTO") 	TYPE TamSX3("DXL_RDMTO")[3]		OF oBrwP1 //"%Rend."

	ACTIVATE FWFORMBROWSE oBrwP1

	UBAC005RT()

	// Instancia o layer
	oFWL := FWLayer():New()

	// Inicia o Layer
	oFWL:init( oFolder:aDialogs[2],.F.)

	// Cria uma linha unica para o Layer
	oFWL:addLine( 'SUP', 50 , .F.)
	oFWL:addLine( 'INF', 50 , .F.)

	// Cria colunas
	oFWL:addCollumn( 'ESQ', 70, .T., 'INF' )
	oFWL:addCollumn( 'DIR', 30, .T., 'INF' )

	oPnlLine:= oFWL:getLinePanel('SUP')
	oPnlEsq := oFWL:getColPanel( 'ESQ', 'INF' )
	oPnlDir := oFWL:getColPanel( 'DIR', 'INF')

	//-------------------------------------------------------------------
	// Define o Browse Cargas
	//-------------------------------------------------------------------
	DEFINE FWFORMBROWSE oBrwP2 DATA TABLE ALIAS cAlT21 DESCRIPTION STR0015 OF oPnlLine //"Cargas"
	oBrwP2:DisableDetails()
	oBrwP2:SetTemporary(.T.)
	oBrwP2:SetFieldFilter(@aArqTRBP2)
	oBrwP2:SetdbFFilter(.T.)
	oBrwP2:SetUseFilter(.T.)
	oBrwP2:bChange := {|| UBAC005G2()}	

	ADD COLUMN oColumn DATA { || &(aArqTRBP2[4,1]) } TITLE STR0016	SIZE  aArqTRBP2[04,1];
		PICTURE PesqPict("DXM","DXM_PLACA" )	TYPE TamSX3("DXM_PLACA")[3]	OF oBrwP2 //"Veículo"
	ADD COLUMN oColumn DATA { || &(aArqTRBP2[5,1]) } TITLE STR0017	SIZE  aArqTRBP2[05,1];
		PICTURE PesqPict("DXM","DXM_DTEMIS")	TYPE TamSX3("DXM_DTEMIS")[3]OF oBrwP2 //"Entrada"
	ADD COLUMN oColumn DATA { || &(aArqTRBP2[6,1]) } TITLE STR0018	SIZE  aArqTRBP2[06,1];
		PICTURE PesqPict("DXL","DXL_CODIGO")	TYPE TamSX3("DXL_CODIGO")[3]OF oBrwP2 //"Fardão"
	ADD COLUMN oColumn DATA { || &(aArqTRBP2[7,1]) } TITLE STR0031	SIZE  aArqTRBP2[07,1];
		PICTURE PesqPict("DXM","DXM_NOTA"  )	TYPE TamSX3("DXM_NOTA")[3]	OF oBrwP2 //"Nota"
	ADD COLUMN oColumn DATA { || &(aArqTRBP2[8,1]) } TITLE STR0019	SIZE  aArqTRBP2[08,1];
		PICTURE PesqPict("DXL","DXL_TALHAO")	TYPE TamSX3("DXL_TALHAO")[3]OF oBrwP2 //"Talhão"
	ADD COLUMN oColumn DATA { || &(aArqTRBP2[9,1]) } TITLE STR0020	SIZE  aArqTRBP2[09,1];
		PICTURE PesqPict("DXS","DXS_PSSUBT")	TYPE TamSX3("DXS_PSSUBT")[3]OF oBrwP2 //"Peso Bruto"
	ADD COLUMN oColumn DATA { || &(aArqTRBP2[10,1])} TITLE STR0021	SIZE  aArqTRBP2[10,1];
		PICTURE PesqPict("DXS","DXS_PSLIQU")	TYPE TamSX3("DXS_PSLIQU")[3]OF oBrwP2 //"Peso Líquido"
	ADD COLUMN oColumn DATA { || &(aArqTRBP2[11,1])} TITLE STR0013	SIZE  aArqTRBP2[11,1];
		PICTURE PesqPict("DXL","DXL_RDMTO" )	TYPE TamSX3("DXL_RDMTO")[3]	OF oBrwP2 //"%Rend."

	ACTIVATE FWFORMBROWSE oBrwP2

	//-------------------------------------------------------------------
	// Define o Browse Fardos
	//-------------------------------------------------------------------
	DEFINE FWFORMBROWSE oBrwP3 DATA TABLE ALIAS cAlT22 DESCRIPTION STR0022 OF oPnlEsq //"Fardos"
	oBrwP3:DisableDetails()
	oBrwP3:SetTemporary(.T.)
	oBrwP3:SetFieldFilter(@aArqTRBP3)
	oBrwP3:SetdbFFilter(.T.)
	oBrwP3:SetUseFilter(.T.)
	ADD COLUMN oColumn DATA { || &(aArqTRBP3[1,1]) } TITLE STR0023	SIZE  aArqTRBP3[1,1]  PICTURE PesqPict("DXI","DXI_CODIGO") 	TYPE TamSX3("DXI_CODIGO")[3]	OF oBrwP3 //"Fardo"
	ADD COLUMN oColumn DATA { || &(aArqTRBP3[2,1]) } TITLE STR0024	SIZE  aArqTRBP3[2,1]  PICTURE PesqPict("DXI","DXI_PSLIQU")	TYPE TamSX3("DXI_PSLIQU")[3]	OF oBrwP3 //"Peso Fardo"
//	ADD COLUMN oColumn DATA { || &(aArqTRBP3[11,1])} TITLE STR0020	SIZE  aArqTRBP3[11,1] PICTURE PesqPict("DXI","DXI_PSBRUT")	TYPE TamSX3("DXI_PSBRUT")[3]	OF oBrwP3 //"Peso BRUTO"
	ADD COLUMN oColumn DATA { || &(aArqTRBP3[4,1]) } TITLE STR0014	SIZE  aArqTRBP3[4,1]  PICTURE PesqPict("DXI","DXI_COSTEL")	TYPE TamSX3("DXI_COSTEL")[3]	OF oBrwP3 //"Peso Fardo"
	ADD COLUMN oColumn DATA { || &(aArqTRBP3[3,1]) } TITLE STR0025	SIZE  aArqTRBP3[3,1]  PICTURE PesqPict("DXI","DXI_PRENSA") 	TYPE TamSX3("DXI_PRENSA")[3]	OF oBrwP3 //"Prensa"

	ACTIVATE FWFORMBROWSE oBrwP3

	//-------------------------------------------------------------------
	// Define o Browse Fardos Beneficiados por Prensa
	//-------------------------------------------------------------------
	DEFINE FWFORMBROWSE oBrwP4 DATA TABLE ALIAS cAlT23 DESCRIPTION STR0026 OF oPnlDir //"Fardos Beneficiados por Prensa"
	oBrwP4:DisableDetails()
	oBrwP4:SetTemporary(.T.)
	oBrwP4:SetFieldFilter(@aArqTRBP4)
	oBrwP4:SetdbFFilter(.T.)
	oBrwP4:SetUseFilter(.T.)
	ADD COLUMN oColumn DATA { || &(aArqTRBP4[1,1]) } TITLE STR0027	SIZE  aArqTRBP4[1,1] ;
		PICTURE PesqPict("DXI","DXI_PRENSA") 	TYPE TamSX3("DXI_PRENSA")[3]	OF oBrwP4 //"Prensa"
	ADD COLUMN oColumn DATA { || &(aArqTRBP4[2,1]) } TITLE STR0028	SIZE  aArqTRBP4[2,1]	;
		PICTURE PesqPict("DXS","DXS_PSLIQU")	TYPE TamSX3("DXS_PSLIQU")[3]	OF oBrwP4 //"Peso Total"
	ADD COLUMN oColumn DATA { || &(aArqTRBP4[4,1]) } TITLE STR0034	SIZE  aArqTRBP4[4,1]	;
		PICTURE PesqPict("DXS","DXS_PSLIQU")	TYPE "N"							OF oBrwP4 //"Peso Total"
	ADD COLUMN oColumn DATA { || &(aArqTRBP4[3,1]) } TITLE STR0029	SIZE  aArqTRBP4[3,1]	;
		PICTURE PesqPict("DXL","DXL_RDMTO") 	TYPE TamSX3("DXL_RDMTO")[3]	OF oBrwP4 //"%Perc."

	ACTIVATE FWFORMBROWSE oBrwP4

	ACTIVATE MSDIALOG oDlg CENTER

	//*Apaga os arquivos temporários
	UBAC005AZ(aMatArq)
Return


/*/{Protheus.doc} fAtuFolder
Função para atualizar pasta/folder quando é alterado o folder
@type function
@version P12
@author claudineia.reinert
@since 09/09/2022
@param nPasta, numeric, numero da pasta/folder
@return Logical, valor padrão
/*/
Static Function fAtuFolder(nPasta)

	If nPasta = 2 //só atualiza se alterou para o folder 2
		Processa({|| UBAC005G1()})
	EndIf
Return .T.
/*
############################################################################
# Função   : CRIATRBS                                                      #
# Descrição: Filtra tabelas, cria e carrega arquivos temporários           #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 03/09/2014                                                    #
############################################################################
*/
Static Function CRIATRBS(nOp)
	Local nx		:= 0
	Local cWhereDXL := ""
	Local cWhereDXM := ""
	Local cUN       := ""
	aTotais := {0,0,0,0,0}
	nQtdReg := 0
    
    cUN       := if(!Empty(mv_par10), mv_par10,"")
//-------------------------------------------------
// Monta Query lista o geral de fardos beneficiados
//-------------------------------------------------
// Safra
	cWhereDXL := " AND DXL.DXL_SAFRA = '"+mv_par01+"' "
	
// Produto
	If !Empty(mv_par02)
		cWhereDXL += " AND DXL.DXL_CODPRO = '"+mv_par02+"' "
	EndIf
		
// Produtor
	If !Empty(mv_par03)
		cWhereDXL += " AND DXL.DXL_PRDTOR = '"+mv_par03+"' "
	// Loja
		If !Empty(mv_par04)
			cWhereDXL += " AND DXL.DXL_LJPRO = '"+mv_par04+"' "
		EndIf
	EndIf
		
// Fazenda
	If !Empty(mv_par05)
		cWhereDXL += " AND DXL.DXL_FAZ = '"+mv_par05+"'"
	EndIf
		
// Talhao
	If !Empty(mv_par06)
		cWhereDXL += " AND DXL.DXL_TALHAO = '"+mv_par06+"' "
	EndIf

// Variedade
	If !Empty(mv_par07)
		cWhereDXL += " AND DXL.DXL_CODVAR = '"+mv_par07+"' "
	EndIf

	If !Empty(mv_par08) .And. !Empty(mv_par09)
		cWhereDXL += " AND DXL.DXL_DTBEN BETWEEN '"+DTOS(mv_par08)+"' AND '"+DTOS(mv_par09)+"'"
	EndIf

	cWhereDXM += " DXM.DXM_CODIGO = DXL.DXL_CODROM "

	cWhereDXL := "%"+cWhereDXL+"%"
	cWhereDXM := "%"+cWhereDXM+"%"

	If Select(cAlias1) > 0
		(cAlias1)->(dbCloseArea())
	EndIf

	cAlias1 := GetNextAlias()
	BeginSql Alias cAlias1

		SELECT DXL.DXL_PRDTOR AS PRODUTOR,
		DXL.DXL_LJPRO AS LOJA,
		DXL.DXL_FAZ AS FAZENDA,
		DXL.DXL_CODIGO AS CODIGO,
		DXL.DXL_TALHAO AS TALHAO,
		DXL.DXL_DTBEN  AS DATABN,
		MAX(DXI.DXI_HORA) AS HORA,
		DXL.DXL_CODTUR AS TURNO,
		MAX(DXL.DXL_SAFRA) AS DXL_SAFRA,
		SUM(DXI.DXI_PSLIQU) AS PS_FARDINHOS,
		DXM.DXM_PLACA       AS PLACA,
		DXM.DXM_NOTA 	      AS NOTA,
		MAX(DXM.DXM_DTEMIS) AS DXM_DTEMIS,
		MAX(DXM.DXM_PSBRUT) AS DXM_PSBRUT,
		COUNT(DXI.DXI_CODIGO) AS TOTAL_FARDINHOS,
		SUM(DXI.DXI_PSLIQU)AS PS_TOTFARDI,
		MAX((CASE WHEN DXL.DXL_PSLIQU = 0 THEN DXL.DXL_PSESTI Else DXL.DXL_PSLIQU END)) AS PS_FARDAO,
		MAX(DXM.DXM_PLACA)  AS DXM_PLACA,
		MAX(DXM.DXM_DTEMIS) AS DXM_DTEMIS,
		MAX(DXM.DXM_NOTA)   AS DXM_NOTA
		FROM %table:DXL% DXL
		INNER JOIN %table:DXI% DXI ON DXI.%notDel%
		AND DXI.DXI_FILIAL = %xFilial:DXI%
		AND DXI.DXI_FARDAO = DXL.DXL_CODIGO
		AND DXI.DXI_SAFRA = DXL.DXL_SAFRA
		AND DXI.DXI_PRDTOR = DXL.DXL_PRDTOR
		AND DXI.DXI_FAZ = DXL.DXL_FAZ
		left JOIN %table:DXM% DXM ON DXM.%notDel%
		AND DXM.DXM_FILIAL = %xFilial:DXI%
		AND %Exp:cWhereDXM%
		WHERE DXL.%notDel%
		AND DXL.DXL_CODUNB = %Exp:cUN%
		AND DXL.DXL_FILIAL = %xFilial:DXL%
		%Exp:cWhereDXL%
		GROUP BY DXL.DXL_PRDTOR,DXL.DXL_LJPRO,DXL.DXL_FAZ,DXL.DXL_CODIGO,DXL.DXL_TALHAO,DXL.DXL_SAFRA,DXL.DXL_CODVAR,
		DXM.DXM_PLACA,DXM.DXM_NOTA,DXM.DXM_PSBRUT,DXL.DXL_DTBEN,DXL.DXL_CODTUR, DXL.DXL_CODPRO
	EndSQL
	//ORDER BY DXL.DXL_FAZ,DXL.DXL_PRDTOR,DXL.DXL_CODIGO,DXL.DXL_DTBEN,DXL.DXL_CODTUR //---removido order by para otimizar query
	
//-------------------------------------------------
// Monta Query lista FARDOS
//-------------------------------------------------
	cAlias3 := GetNextAlias()
	BeginSQL Alias cAlias3
		SELECT
		DXI_CODIGO AS FARDO
		,DXI_PSLIQU AS PESO
		,DXI_PSBRUT AS PESOBRUTO
		,DXI_PRENSA AS PRENSA
		,DXI_PRDTOR AS PRODUTOR
		,DXI_FAZ   AS FAZENDA
		,DXI_LJPRO AS LOJA
		,DXI_FARDAO AS FARDAO
		,(CASE WHEN DXI_COSTEL = '2' THEN 'S'ELSE 'N' END) AS COSTELADO
		FROM
		%table:DXI% DXI, %table:DXL% DXL
		WHERE
		DXI.%notDel% AND
		DXI.DXI_CODUNB = %Exp:cUN% AND
		DXI.DXI_FILIAL = %xFilial:DXI% AND
		DXI.DXI_FARDAO = DXL.DXL_CODIGO AND
		DXI.DXI_SAFRA = DXL.DXL_SAFRA AND
		DXI.DXI_PRDTOR = DXL.DXL_PRDTOR AND
		DXI.DXI_FAZ = DXL.DXL_FAZ AND
		DXI.DXI_CODVAR = DXL.DXL_CODVAR
		%Exp:cWhereDXL%
	EndSQL
	//ORDER BY PRENSA	,FARDO //---removido order by para otimizar query
	
//-------------------------------------------------
// Monta Query lista Fardos beneficiados por prensa
//-------------------------------------------------
	cAlias4 := GetNextAlias()
	BeginSQL Alias cAlias4
		SELECT
		DXI_PRENSA AS PRENSA
		,DXL_PRDTOR AS PRODUTOR
		,DXL_FAZ   AS FAZENDA
		,DXL_LJPRO AS LOJA
		,DXL.DXL_DTBEN  AS DATABN
		,DXL_CODIGO AS FARDAO
		,MAX((CASE WHEN DXL.DXL_PSLIQU = 0 THEN DXL.DXL_PSESTI Else DXL.DXL_PSLIQU END)) AS PESO
		,COUNT(DXI.DXI_PRENSA) AS QTDPRENSA
		,SUM(DXI_PSLIQU) AS TOTPSLIQU
		FROM %table:DXI% DXI, %table:DXL% DXL
		WHERE
		DXI.%notDel% AND
		DXI.DXI_CODUNB = %Exp:cUN%	AND
		DXI.DXI_FILIAL = %xFilial:DXI% AND
		DXI.DXI_FARDAO = DXL.DXL_CODIGO AND
		DXI.DXI_SAFRA = DXL.DXL_SAFRA AND
		DXI.DXI_PRDTOR = DXL.DXL_PRDTOR AND
		DXI.DXI_FAZ = DXL.DXL_FAZ AND
		DXI.DXI_CODVAR = DXL.DXL_CODVAR
		%Exp:cWhereDXL%
		GROUP BY DXI.DXI_PRENSA,DXL.DXL_CODIGO,DXL.DXL_PRDTOR,DXL.DXL_FAZ,DXL.DXL_LJPRO, DXL.DXL_SAFRA,
		         DXL.DXL_DTBEN,DXL.DXL_TALHAO,DXL.DXL_CODVAR, DXL.DXL_CODPRO
		
	EndSQL
	//ORDER BY DXI.DXI_PRENSA //---removido order by para otimizar query
	
	UBAC005AZ(aMatArq,"Z")

	ARGSETIFARQUI(cAlias1)
	cCodFardao := ''
	While (cAlias1)->(!Eof())
		If !AGRIFSEETRB(cAlt1,(cAlias1)->FAZENDA+(cAlias1)->PRODUTOR+(cAlias1)->DATABN+(cAlias1)->TURNO)
			Reclock(cAlt1,.T.)
			(cAlt1)->NJ0_CODENT	:= (cAlias1)->PRODUTOR
			(cAlt1)->NJ0_NOME 	:= Posicione("NJ0",1,FWxFilial("NJ0")+(cAlias1)->(PRODUTOR+LOJA),"NJ0_NOME")
			(cAlt1)->DXL_FAZ    := (cAlias1)->FAZENDA
			(cAlt1)->NN2_NOME 	:= Posicione("NN2",3,FWxFilial("NN2")+(cAlias1)->(PRODUTOR+LOJA+FAZENDA),"NN2_NOME")
			(cAlt1)->DXI_DATA 	:= Stod((cAlias1)->DATABN)
			(cAlt1)->DXI_CODTUR := (cAlias1)->TURNO
			(cAlt1)->DXL_CODIGO := (cAlias1)->CODIGO
		Else
			Reclock(cAlt1,.f.)
		EndIf

		aTotais[1] += 1
		(cAlt1)->DXM_PSLONA += 1
		(cAlt1)->DXS_PSSUBT += (cAlias1)->TOTAL_FARDINHOS // TOTAL DE FARDINHOS DO FARDÃO
		aTotais[3] += (cAlias1)->TOTAL_FARDINHOS          // TOTAL GERAL DE FARDOS

		(cAlt1)->DXS_PSLIQU += (cAlias1)->PS_FARDAO  // PESO DO FARDÃO
		aTotais[2] += (cAlias1)->PS_FARDAO           // PESO TOTAL FARDÃO

		(cAlt1)->TOTPSFARDI += (cAlias1)->PS_TOTFARDI // PESO DOS FARDINHOS
		aTotais[4] += (cAlias1)->PS_TOTFARDI
		(cAlt1)->DXL_RDMTO	  := ((cAlias1)->PS_TOTFARDI /(cAlias1)->PS_FARDAO)*100
		(cAlt1)->(MsUnlock())

		cCodFardao := (cAlias1)->CODIGO

		(cAlias1)->(dbSkip())
	End

	If !Empty(aTotais[4])
		aTotais[5] := (aTotais[4] / aTotais[2]) * 100
	EndIf

	(cAlias1)->(dbGoTop())
	cCodFardao := ''
	While (cAlias1)->(!Eof())
		If !AGRIFSEETRB(cAlt2,(cAlias1)->FAZENDA+(cAlias1)->PRODUTOR+(cAlias1)->DATABN+(cAlias1)->TURNO+(cAlias1)->CODIGO)
			Reclock(cAlt2, .T.)
			(cAlt2)->NJ0_CODENT	:= (cAlias1)->PRODUTOR
			(cAlt2)->NJ0_LOJENT := (cAlias1)->LOJA
			(cAlt2)->DXL_FAZ   	:= (cAlias1)->FAZENDA
			(cAlt2)->DXM_PLACA 	:= (cAlias1)->PLACA
			(cAlt2)->DXM_DTEMIS := STOD((cAlias1)->DXM_DTEMIS)
			(cAlt2)->DXL_CODIGO := (cAlias1)->CODIGO
			(cAlt2)->DXM_NOTA 	:= (cAlias1)->NOTA
			(cAlt2)->DXL_TALHAO := (cAlias1)->TALHAO
			(cAlt2)->DXI_CODTUR := (cAlias1)->TURNO
			(cAlt2)->DXI_DATA   := Stod((cAlias1)->DATABN)
			(cAlt2)->DXI_FARDAO := (cAlias1)->CODIGO
		Else
			Reclock(cAlt2, .f.)
		EndIf
		(cAlt2)->DXS_PSSUBT := (cAlias1)->DXM_PSBRUT //PESO BRUTO DO FARDAO
		(cAlt2)->DXM_PSLIQU := (cAlias1)->PS_FARDAO // PESO LIQUIDO DO FARDAO
		(cAlt2)->DXL_RDMTO  := ( (cAlias1)->PS_TOTFARDI / (cAlias1)->PS_FARDAO) *100 //RENDIMENTO
		(cAlt2)->(MsUnlock())
		cCodFardao := (cAlias1)->CODIGO
		(cAlias1)->(dbSkip())
	End

	ARGSETIFARQUI(cAlias3)
	While (cAlias3)->(!Eof())
		Reclock(cAlt3, .T.)
		(cAlt3)->NJ0_CODENT	:= (cAlias3)->PRODUTOR
		(cAlt3)->NJ0_LOJENT	:= (cAlias3)->LOJA
		(cAlt3)->DXL_FAZ   	:= (cAlias3)->FAZENDA
		(cAlt3)->DXI_CODIGO := (cAlias3)->FARDO
		(cAlt3)->DXI_PSLIQU := (cAlias3)->PESO
		(cAlt3)->DXI_PRENSA := (cAlias3)->PRENSA
		(cAlt3)->DXI_COSTEL := (cAlias3)->COSTELADO
		(cAlt3)->DXI_FARDAO := (cAlias3)->FARDAO
		(cAlt3)->DXI_PSBRUT := (cAlias3)->PESOBRUTO
		(cAlt3)->(MsUnlock())
		(cAlias3)->(dbSkip())
	End

	ARGSETIFARQUI(cAlias4)
	While (cAlias4)->(!Eof())
		Reclock(cAlt4, .T.)
		(cAlt4)->DXI_PRENSA := (cAlias4)->PRENSA
		(cAlt4)->DXS_PSLIQU := (cAlias4)->TOTPSLIQU
		(cAlt4)->DXL_RDMTO	:= ((cAlias4)->TOTPSLIQU / (cAlias4)->PESO ) * 100
		(cAlt4)->NJ0_CODENT := (cAlias4)->PRODUTOR
		(cAlt4)->NJ0_LOJENT	:= (cAlias4)->LOJA
		(cAlt4)->DXL_FAZ    := (cAlias4)->FAZENDA
		(cAlt4)->DXI_FARDAO := (cAlias4)->FARDAO
		(cAlt4)->DXM_PSLONA := (cAlias4)->QTDPRENSA
		(cAlt4)->(MsUnlock())
		(cAlias4)->(dbSkip())
	End

	(cAlias1)->(dbCloseArea())
	(cAlias3)->(dbCloseArea())
	(cAlias4)->(dbCloseArea())

// Montar seta a grids 1
	ARGSETIFARQUI(cAlT1)
	AGRAREAORDE(cAlt1,1)

	aArqTRBP1 := {}
	For nx := 1 To Len(aAlT1)
		Aadd(aArqTRBP1,{aAlT1[nx,1],aAlT1[nx,5],aAlT1[nx,2],aAlT1[nx,3],aAlT1[nx,4],Alltrim(aAlT1[nx,6])})
	Next nx

	If Type("oBrwP1") <> "U"
		oBrwP1:Refresh(.T.)
	EndIf

	If Type("oFolder") <> "U"
		UBAC005RT()
	EndIf
	UBAC005G1()
	
Return

/*
############################################################################
# Função   : UBAC005G1                                                     #
# Descrição: Carrega arquivo o temporário da primeira grid do folder 2     #
# Autor    : Inácio Luiz Kolling                                           #
# Data     : 03/09/2014                                                    #
############################################################################
*/
Function UBAC005G1()
	Local cChavea := (cAlT1)->&(aArqTRBP1[3][1])+(cAlT1)->&(aArqTRBP1[1][1])+Dtos((cAlT1)->&(aArqTRBP1[5][1]))+(cAlT1)->&(aArqTRBP1[6][1]),nx
	UBAC005AZ({{cAlT21,cNoT21}},"Z")
	If AGRIFSEETRB(cAlT2,cChavea)
		While !Eof() .And. (cAlT2)->DXL_FAZ+(cAlT2)->NJ0_CODENT+Dtos((cAlt2)->DXI_DATA)+(cAlt2)->DXI_CODTUR = cChavea
			Reclock(cAlt21, .T.)
			(cAlt21)->NJ0_CODENT	:= (cAlT2)->NJ0_CODENT
			(cAlt21)->NJ0_LOJENT	:= (cAlT2)->NJ0_LOJENT
			(cAlt21)->DXL_FAZ  		:= (cAlT2)->DXL_FAZ
			(cAlt21)->DXM_PLACA 	:= (cAlT2)->DXM_PLACA
			(cAlt21)->DXM_DTEMIS	:= (cAlT2)->DXM_DTEMIS
			(cAlt21)->DXL_CODIGO 	:= (cAlT2)->DXL_CODIGO
			(cAlt21)->DXM_NOTA 		:= (cAlT2)->DXM_NOTA
			(cAlt21)->DXL_TALHAO 	:= (cAlT2)->DXL_TALHAO
			(cAlt21)->DXS_PSSUBT	:= (cAlT2)->DXS_PSSUBT
			(cAlt21)->DXM_PSLIQU	:= (cAlT2)->DXM_PSLIQU
			(cAlt21)->DXL_RDMTO  	:= (cAlT2)->DXL_RDMTO
			(cAlt21)->DXI_CODTUR 	:= (cAlT2)->DXI_CODTUR
			(cAlt21)->DXI_FARDAO 	:= (cAlT2)->DXI_FARDAO
			(cAlt21)->(MsUnlock())
			(cAlT2)->(dbSkip())
		End
		ARGSETIFARQUI(cAlT21)
	EndIf

	aArqTRBP2 := {}
	For nx := 1 To Len(aAlT2)
		Aadd(aArqTRBP2,{aAlT2[nx,1],aAlT2[nx,5],aAlT2[nx,2],aAlT2[nx,3],aAlT2[nx,4],Alltrim(aAlT2[nx,6])})
	Next nx
	If Type("oBrwP2") <> "U"
		oBrwP2:Refresh(.T.)
	EndIf

	UBAC005G2()
Return

/*
###################################################################################
# Função   : UBAC005G2                                                            #
# Descrição: Carrega arquivo os temporários da segunda e terceira grid do folder 2#
# Autor    : Inácio Luiz Kolling                                                  #
# Data     : 03/09/2014                                                           #
###################################################################################
*/
Function UBAC005G2()
	Local cChavea := (cAlT21)->&(aArqTRBP2[3][1])+(cAlT21)->&(aArqTRBP2[1][1])+(cAlT21)->&(aArqTRBP2[6][1])
	Local nx
	UBAC005AZ({{cAlT22,cNoT22}},"Z")
	DbselectArea(cAlT2)
	If AGRIFSEETRB(cAlT3,cChavea)
		While !Eof() .And. (cAlT3)->DXL_FAZ+(cAlT3)->NJ0_CODENT+(cAlT3)->DXI_FARDAO = cChavea
			Reclock(cAlt22, .T.)
			(cAlt22)->NJ0_CODENT := (cAlt3)->NJ0_CODENT
			(cAlt22)->NJ0_LOJENT := (cAlt3)->NJ0_LOJENT
			(cAlt22)->DXL_FAZ    := (cAlt3)->DXL_FAZ
			(cAlt22)->DXI_CODIGO := (cAlt3)->DXI_CODIGO
			(cAlt22)->DXI_PSLIQU := (cAlt3)->DXI_PSLIQU
			(cAlt22)->DXI_PRENSA := (cAlt3)->DXI_PRENSA
			(cAlt22)->DXI_COSTEL := (cAlt3)->DXI_COSTEL
			(cAlt22)->DXI_PSBRUT := (cAlt3)->DXI_PSBRUT // peso bruto
			(cAlt22)->(MsUnlock())
			(cAlT3)->(dbSkip())
		End
		ARGSETIFARQUI(cAlT22)
	EndIf
	aArqTRBP3 := {}
	For nx := 1 To Len(aAlT3)
		Aadd(aArqTRBP3,{aAlT3[nx,1],aAlT3[nx,5],aAlT3[nx,2],aAlT3[nx,3],aAlT3[nx,4],Alltrim(aAlT3[nx,6])})
	Next nx

	If Type("oBrwP3") <> "U"
		oBrwP3:Refresh(.T.)
	EndIf

	UBAC005AZ({{cAlT23,cNoT23}},"Z")
	DbselectArea(cAlT4)
	If AGRIFSEETRB(cAlT4,cChavea)
		While !Eof() .And. (cAlT4)->DXL_FAZ+(cAlT4)->NJ0_CODENT+(cAlT4)->DXI_FARDAO = cChavea
			If !AGRIFSEETRB(cAlT23,(cAlT4)->DXL_FAZ+(cAlT4)->NJ0_CODENT+(cAlT4)->DXI_FARDAO+(cAlT4)->DXI_PRENSA)
				Reclock(cAlt23,.T.)
				(cAlt23)->DXL_FAZ    := (cAlT4)->DXL_FAZ
				(cAlt23)->NJ0_CODENT := (cAlT4)->NJ0_CODENT
				(cAlt23)->DXI_PRENSA := (cAlT4)->DXI_PRENSA
				(cAlt23)->NJ0_LOJENT := (cAlT4)->NJ0_LOJENT
				(cAlt23)->DXI_CODIGO := (cAlT4)->DXI_CODIGO
				(cAlt23)->DXI_FARDAO := (cAlT4)->DXI_FARDAO
				(cAlt23)->DXM_PSLONA := (cAlT4)->DXM_PSLONA
			Else
				Reclock(cAlt23,.f.)
			EndIf
			(cAlt23)->DXS_PSLIQU += (cAlT4)->DXS_PSLIQU
			(cAlt23)->DXL_RDMTO	+= (cAlT4)->DXL_RDMTO
			(cAlt23)->(MsUnlock())
			(cAlT4)->(dbSkip())
		End
		ARGSETIFARQUI(cAlT23)
	EndIf
	aArqTRBP4 := {}
	For nx := 1 To Len(aAlT4)
		Aadd(aArqTRBP4,{aAlT4[nx,1],aAlT4[nx,5],aAlT4[nx,2],aAlT4[nx,3],aAlT4[nx,4],Alltrim(aAlT4[nx,6])})
	Next nx

	If Type("oBrwP4") <> "U"
		oBrwP4:Refresh(.T.)
	EndIf

Return .t.

/*
###################################################################################
# Função   : UBAC005AZ                                                            #
# Descrição: Apaga fisicamente ou limpa os arquivos temporários                   #
# Autor    : Inácio Luiz Kolling                                                  #
# Data     : 08/09/2014                                                           #
###################################################################################
*/
Static Function UBAC005AZ(aMatAr,cTipo)
	Local cTipOp := If(cTipo = Nil,"A",cTipo),nx
	For nx := 1 To Len(aMatAr)
		If cTipOp = "A"
			AGRDELETRB(aMatAr[nx,1],aMatAr[nx,2])
		Else
			DbSelectArea(aMatAr[nx,1])
			Zap
		EndIf
	Next nx
Return

/*
###################################################################################
# Função   : UBAC005RT                                                            #
# Descrição: Recalcula os totalizadores após confirmar o(s) filtro(s)             #
# Autor    : Inácio Luiz Kolling                                                  #
# Data     : 16/09/2014                                                           #
###################################################################################
*/
Function UBAC005RT()
	oBrwP1:ExecuteFilter(.t.)
	oBrwP1:SetUseFilter(.T.)
	aTotais := {0,0,0,0,0}
	ARGSETIFARQUI(cAlT1)
	While !Eof()
		aTotais[1] += (cAlT1)->DXM_PSLONA
		aTotais[2] += (cAlT1)->DXS_PSLIQU					// PESO TOTAL FARDÃO
		aTotais[3] += (cAlT1)->DXS_PSSUBT					// TOTAL GERAL DE FARDOS
		aTotais[4] += (cAlT1)->TOTPSFARDI					// PESO DOS FARDINHOS
		aTotais[5]	 := (aTotais[4] / aTotais[2])*100 		// RENDIMENTO
		DbSkip()
	End
	AGRMOSTOTAIS(aMatCam,aTotais,oFolder:aDialogs[1],@oBrwP1)
	ARGSETIFARQUI(cAlT1)
Return
