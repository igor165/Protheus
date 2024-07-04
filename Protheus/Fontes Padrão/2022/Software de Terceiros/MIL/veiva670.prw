// ษออออออออหออออออออป
// บ Versao บ 11     บ
// ศออออออออสออออออออผ

#include "protheus.ch"
#include "VEIVA670.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ VEIVA670 ณ Autor ณ  Rafael Goncalves     ณ Data ณ 01/07/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Vigencia do F&I                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA670()

Private aCampos := {}
Private aRotina := MenuDef()
Private cCadastro := STR0001 // Vigencia do F&I
Private aCores    := {	{'VNR->VNR_ATIVO == "1"','BR_VERDE'},;		//Ativo
						{'VNR->VNR_ATIVO == "0"','BR_VERMELHO'}}	//Inativo
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Endereca a funcao de BROWSE                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
mBrowse( 6, 1,22,75,"VNR",,,,,,aCores)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOA670I    บAutor  ณRafael Goncalves    บ Data ณ  27/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณIncluir                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OA670I(cAlias,nReg,nOpc)

//variaveis controle de janela
Local aObjects  := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam   := 0
Local nPos      := 0
Local nPosic    := 0
Local ni        := 0
//
Local aFilAtu   := FWArrFilAtu()
Local aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local nCont     := 0
Local cBkpFilAnt:= cFilAnt
//
Local lAltCpo   := .t.
Local nOrdCpo   := 0
Private lFiliais:= .f.	//marcar todos filial
Private lTipVAI := .f.	//marcar todos tipo gerente
Private lLstBox := .f.	//marcar todos List box
Private oVerd   := LoadBitmap( GetResources() , "BR_VERDE" )	// Selecionado
Private oVerm   := LoadBitmap( GetResources() , "BR_VERMELHO" )	// Nao Selecionado
Private aFiliais:= {} 	// Filiais
Private aTipGer := {} 	// Grupo do Modelo
Private aBoxTTec:= X3CBOXAVET("VAI_TIPTEC","0")  // cbox do campo
Private aTecVAI := {} 	// Veiculos Total
Private cEstVei := "2"
Private aEstVei := X3CBOXAVET("VAI_ESTVEI","0")  // cbox do campo
Private cTipVei :="0"
Private aTipVei := X3CBOXAVET("VAI_TIPVEI","0")  // cbox do campo
Private cRMenor := space(2)
Private dDatIni := ctod(" ")
Private dDatFim := ctod(" ")
Private oOk     := LoadBitmap( GetResources(), "LBTIK" )
Private oNo     := LoadBitmap( GetResources(), "LBNO" )

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0, 080 , .T. , .F. } )
AAdd( aObjects, { 0, 000 , .T. , .T. } )

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPos  := MsObjSize (aInfo, aObjects,.F.)

If FWModeAccess("VAI",3) == "E" // Exclusivo
	//Levanta as Filiais
	For nCont := 1 to Len(aSM0)
		cFilAnt := aSM0[nCont]
		aAdd( aFiliais, { .f. , cFilAnt , FWFilialName() })
	Next
	cFilAnt := cBkpFilAnt
Else
	aAdd( aFiliais, { .f. , cFilAnt , FWFilialName() })
EndIf

//adiciona os tipo de gerente.
For ni:=1 to len(aBoxTTec)
	aAdd(aTipGer,{.f.,aBoxTTec[ni],"",""})
Next

//verifica conteudo dos arrays
If Len(aFiliais) <= 0
	aAdd(aFiliais,{.f.,"",""})
Endif
If Len(aTipGer) <= 0
	aAdd(aTipGer,{.f.,"","",""})
EndIF
If Len(aTecVAI) <= 0
	aAdd(aTecVAI,{.f.," "," "," "," "," "," "," "," ",ctod(""),ctod(""),"" })
Endif

DEFINE MSDIALOG oVigeFI FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE STR0001 OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Vigencia do F&I
oVigeFI:lEscClose := .F.

//divide a janela em tres colunas.
nTam := ( aPos[1,4] / 4 )
nPosic := 60

@ aPos[1,1],aPos[1,2]+(nTam*0) TO aPos[2,1]-001,(nTam*2)+nPosic LABEL STR0002 OF oVigeFI PIXEL // Filtro
// FILIAL 				//
@ aPos[1,1]+008,aPos[1,2]+(nTam*0)+3 LISTBOX oLbFil FIELDS HEADER "",STR0003,STR0004 COLSIZES 10,20,40 SIZE nTam-5,aPos[1,3]-aPos[1,1]-10 OF oVigeFI PIXEL ON DBLCLICK (FS_TIK("FIL",oLbFil:nAt,nOpc)) // Filial / Descricao
oLbFil:SetArray(aFiliais)
oLbFil:bLine := { || { 	IIf(aFiliais[oLbFil:nAt,1],oVerd,oVerm) , aFiliais[oLbFil:nAt,2] , aFiliais[oLbFil:nAt,3] }}

// TIPO DE GERENTE 		//
@ aPos[1,1]+008,aPos[1,2]+(nTam*1)+3 LISTBOX oTpGer FIELDS HEADER "",STR0005 COLSIZES 10,40 SIZE nTam-5,aPos[1,3]-aPos[1,1]-10 OF oVigeFI PIXEL ON DBLCLICK (FS_TIK("GER",oTpGer:nAt,nOpc)) WHEN lAltCpo // Tipo
oTpGer:SetArray(aTipGer)
oTpGer:bLine := { || { 	IIf(aTipGer[oTpGer:nAt,1],oVerd,oVerm) , aTipGer[oTpGer:nAt,2] , aTipGer[oTpGer:nAt,4] }}
// Veiculo Atendimento	//
@ aPos[1,1]+008,(nTam*2)+003  SAY STR0006 SIZE 55,8 OF oVigeFI PIXEL COLOR CLR_BLUE // Estado Veiculo
@ aPos[1,1]+018,(nTam*2)+003  MSCOMBOBOX oEstVei VAR cEstVei SIZE 55,08 COLOR CLR_BLACK ITEMS aEstVei OF oVigeFI PIXEL COLOR CLR_BLUE WHEN lAltCpo
// Tipo de Veiculo		//
@ aPos[1,1]+030,(nTam*2)+003  SAY STR0007 SIZE 55,8 OF oVigeFI PIXEL COLOR CLR_BLUE // Tipo Veiculo
@ aPos[1,1]+040,(nTam*2)+003  MSCOMBOBOX oTipVei VAR cTipVei SIZE 55,08 COLOR CLR_BLACK ITEMS aTipVei OF oVigeFI PIXEL COLOR CLR_BLUE WHEN lAltCpo
// SAIR					//
@ aPos[1,1]+062,(nTam*2)+003 BUTTON oFiltrar PROMPT UPPER(STR0008) SIZE 55,10 OF oVigeFI PIXEL ACTION FS_FILTRAR() // FILTRAR

@ aPos[1,1],(nTam*2)+nPosic+002 TO aPos[2,1]-001,aPos[1,4]-002 LABEL STR0009 OF oVigeFI PIXEL // Alterar
// VALOR FINAL 	//
@ aPos[1,1]+008,(nTam*2)+75 SAY STR0011 SIZE 55,8 OF oVigeFI PIXEL COLOR CLR_BLUE // Nivel Retorno
@ aPos[1,1]+018,(nTam*2)+75 MSGET oRMenor VAR cRMenor VALID(IIF(cRMenor>="00".and.cRMenor<="50",.t.,.f.)) PICTURE "@E 99" SIZE 20,08 OF oVigeFI PIXEL COLOR CLR_BLUE HASBUTTON  WHEN lAltCpo
// DATA INICIAL	//
@ aPos[1,1]+030,(nTam*2)+75 SAY STR0012 SIZE 50,8 OF oVigeFI PIXEL COLOR CLR_BLUE // Data Inicial
@ aPos[1,1]+040,(nTam*2)+75 MSGET oDatIni VAR dDatIni VALID(IIF(dDatIni>dDatFim,dDatFim:=dDatIni,.T.)) PICTURE "@D" SIZE 48,08 OF oVigeFI PIXEL COLOR CLR_BLACK WHEN lAltCpo HASBUTTON
// DATA FINAL 	//
@ aPos[1,1]+052,(nTam*2)+75 SAY STR0013 SIZE 50,8 OF oVigeFI PIXEL COLOR CLR_BLUE // Data Final
@ aPos[1,1]+062,(nTam*2)+75 MSGET odatFim VAR dDatFim VALID(IIF(dDatIni>dDatFim,.F.,.T.)) PICTURE "@D" SIZE 48,08 OF oVigeFI PIXEL COLOR CLR_BLACK  WHEN lAltCpo HASBUTTON

@ aPos[1,1]+040,(nTam*2)+75+70 BUTTON oFiltrar PROMPT UPPER(STR0009) SIZE 55,10 OF oVigeFI PIXEL ACTION FS_ALTERA(oTecVAI:nAt,.t.)  // ALTERAR

// FILTRADOS //
@ aPos[2,1]+002,aPos[2,2] LISTBOX oTecVAI FIELDS HEADER " ",STR0003,STR0015,STR0006,STR0007,STR0017,STR0011,STR0016,STR0012,STR0013 COLSIZES ; // Filial / Tipo Tecnico / Estado Veiculo / Tipo Veiculo / Tecnico / Nivel Retorno / Nivel Ret Ativo / Data Inicial / Data Final
10,55,55,50,50,80,40,40,50,50 SIZE aPos[2,4]-2,aPos[2,3]-aPos[2,1] OF oVigeFI PIXEL ON DBLCLICK (FS_TIK("USU",oTecVAI:nAt,nOpc)) ON CHANGE (FS_ALTERA(oTecVAI:nAt))
oTecVAI:SetArray(aTecVAI)
oTecVAI:bLine := { || { IIf(aTecVAI[oTecVAI:nAt,01],oOk,oNo),;
						aTecVAI[oTecVAI:nAt,02]+aTecVAI[oTecVAI:nAt,12],;
						X3CBOXDESC("VAI_TIPTEC",aTecVAI[oTecVAI:nAt,03]),;
						X3CBOXDESC("VAI_ESTVEI",aTecVAI[oTecVAI:nAt,04]),;
						X3CBOXDESC("VAI_TIPVEI",aTecVAI[oTecVAI:nAt,05]),;
						aTecVAI[oTecVAI:nAt,06]+" - " +aTecVAI[oTecVAI:nAt,07],;
						aTecVAI[oTecVAI:nAt,08],;
						aTecVAI[oTecVAI:nAt,09],;
						aTecVAI[oTecVAI:nAt,10],;
						aTecVAI[oTecVAI:nAt,11] }}

@ aPos[2,1]+002,aPos[2,2]+001 CHECKBOX oLstBox  VAR lLstBox PROMPT "" OF oVigeFI ON CLICK FS_TIK("USU",0,nOpc,"2",lLstBox) SIZE 08,10 PIXEL WHEN lAltCpo

@ aPos[1,1]+008,aPos[1,2]+(nTam*0)+004 CHECKBOX oCFiliais VAR lFiliais PROMPT "" OF oVigeFI ON CLICK FS_TIK("FIL",0,nOpc,"2",lFiliais) SIZE 40,10 PIXEL 
@ aPos[1,1]+008,aPos[1,2]+(nTam*1)+004 CHECKBOX oCTipGer  VAR lTipVAI  PROMPT "" OF oVigeFI ON CLICK FS_TIK("GER",0,nOpc,"2",lTipVAI) SIZE 40,10 PIXEL WHEN lAltCpo


ACTIVATE MSDIALOG oVigeFI ON INIT EnchoiceBar(oVigeFI,{|| Iif(FG_GRAVAR(),oVigeFI:End(),.t.) , .f. },{|| oVigeFI:End() } ) CENTER

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_GRAVAR บAutor  ณRafael Goncalves    บ Data ณ  05/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava as vigencias do F&I                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FG_GRAVAR()
Local lRet := .f.
Local _nk := 1
Local cQuery  := ""
Local cQAlSQL := "ALIASSQL"
Local lGravar := .t.
Local nAviso := 0
Local lAchou := .f.
Local i := 0
Local cCodigo := ""

For i := 1 to Len(aTecVAI)
	if aTecVAI[i,1] .and. !Empty(aTecVAI[i,9])
		lAchou := .t.
	Endif
Next
if lAchou == .f.
	MsgStop(STR0036,STR0035)
	Return(.f.)
Endif

If MsgYesNo(STR0018,STR0019) // Deseja gravar as vigencias seleciondas? / Atencao
	cCodigo := GetSXENum("VNR","VNR_CODIGO")
	For _nk:=1 to Len(aTecVAI)
		If aTecVAI[_nk,1]
			If !Empty(aTecVAI[_nk,9]) .and. !Empty(aTecVAI[_nk,10]) .and. !Empty(aTecVAI[_nk,11])
				cQuery := "SELECT VNR.VNR_DATINI , VNR.VNR_DATFIN , VNR.VNR_ATIVO , VNR.R_E_C_N_O_ AS RECVNR , VAI.VAI_CODUSR , VAI.VAI_NOMTEC "
				cQuery += "FROM "+RetSqlName("VNR")+" VNR "
				cQuery += "LEFT JOIN "  + RetSqlName("VAI")+" VAI ON (VAI.VAI_FILIAL='"+xFilial("VAI")+"'AND VAI.VAI_CODUSR=VNR.VNR_USUARI AND VAI.D_E_L_E_T_=' ') "
				cQuery += "WHERE VNR.VNR_FILIAL='"+xFilial("VNR")+"' AND VNR.VNR_ATIVO='1'"
				cQuery += " AND VNR.VNR_FILUSU='"+aTecVAI[_nk,2]+"' AND VNR.VNR_USUARI='"+aTecVAI[_nk,6]+"'"
				cQuery += " AND VNR.D_E_L_E_T_=' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
				while !( cQAlSQL )->( Eof() )
					If ((( cQAlSQL )->( VNR_DATINI )>=dtos(aTecVAI[_nk,10]) .and. ( cQAlSQL )->( VNR_DATFIN )>=dtos(aTecVAI[_nk,11])) .or. ;
						(( cQAlSQL )->( VNR_DATINI )<=dtos(aTecVAI[_nk,10]) .and. ( cQAlSQL )->( VNR_DATFIN )>=dtos(aTecVAI[_nk,11])) .or. ;
						(( cQAlSQL )->( VNR_DATINI )<=dtos(aTecVAI[_nk,10]) .and. ( cQAlSQL )->( VNR_DATFIN )>=dtos(aTecVAI[_nk,10])) .or. ;
						(( cQAlSQL )->( VNR_DATINI )>=dtos(aTecVAI[_nk,10]) .and. ( cQAlSQL )->( VNR_DATFIN )<=dtos(aTecVAI[_nk,11])))
						If nAviso<>2
							nAviso := Aviso(STR0019,STR0020+ CHR(13) + CHR(10) +  CHR(13) + CHR(10) +; // Atencao / Existe vigencia valida para o usuario:
							( cQAlSQL )->( VAI_CODUSR )+" - " +( cQAlSQL )->( VAI_NOMTEC )+ CHR(13) + CHR(10) +  CHR(13) + CHR(10) +;
							STR0021+TRANSFORM(stod(( cQAlSQL )->( VNR_DATINI )),"@D")+" "+STR0022+" "+TRANSFORM(stod(( cQAlSQL )->( VNR_DATFIN )),"@d")+ CHR(13) + CHR(10) +  CHR(13) + CHR(10)+; // No periodo de: / ate
							STR0023,{STR0024,STR0025,STR0026},3) // Deseja desativar esta vigencia? / Sim / Sim todos / Nao
						EndIF
						If nAviso<>3
							If ( cQAlSQL )->( VNR_ATIVO ) <> "0"
								DBSelectArea("VNR")
								VNR->(DbGoTo(( cQAlSQL )->( RECVNR )))
								RecLock("VNR", .F. )
								VNR->VNR_ATIVO  := "0"//0=Nao;1=Sim
								VNR->VNR_USUDEL := __cUserID
								VNR->VNR_DATDEL := dDataBase
								MsUnLock()
							EndIf
						Else
							lGravar := .f.
						EndIf						
					EndIf
					( cQAlSQL )->( dbSkip() )
				Enddo
				( cQAlSQL )->( dbCloseArea() )
				
				DBSelectArea("VNR")
				dbSetOrder(1)
				if !dbSeek(xFilial("VNR")+aTecVAI[_nk,2]+aTecVAI[_nk,6]+"1")
					If lGravar
						RecLock("VNR", .t. )
						VNR->VNR_FILIAL := xFilial("VNR")
						VNR->VNR_CODIGO := cCodigo
						VNR->VNR_USUARI := aTecVAI[_nk,6]
						VNR->VNR_FILUSU := aTecVAI[_nk,2]
						VNR->VNR_DATINI := aTecVAI[_nk,10]
						VNR->VNR_DATFIN := aTecVAI[_nk,11]
						VNR->VNR_ATIVO  := "1"//0=Nao;1=Sim
						VNR->VNR_USUINC := __cUserID
						VNR->VNR_DATINC := dDataBase
						VNR->VNR_NIVRET := aTecVAI[_nk,9]
						VNR->VNR_USUDEL := ""//aTecVAI[_nk,10]
						VNR->VNR_DATDEL := ctod("  /  /  ")//aTecVAI[_nk,10]
						MsUnLock()
					Endif
				EndIf
			EndIf
		EndIf
	Next
	ConfirmSX8()
	lRet := .t.
EndIF
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ALTERA บAutor  ณRafael Goncalves    บ Data ณ  05/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Alterado os valores da linha selecionada no listbox        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ALTERA(nLinSel,lAlter)

Local i := 0
Default nLinSel:=1
Default lAlter:=.f.


If lAlter
	if Empty(cRMenor) .or. Empty(dDatIni) .or. Empty(dDatFim)
		MsgStop(STR0034,STR0035)
		Return(.f.)
	Endif
Endif
For i:= 1 to Len(aTecVAI)
	if aTecVAI[i,1]
		If !lAlter
			cRMenor := aTecVAI[i,9]
			dDatIni := aTecVAI[i,10]
			dDatFim := aTecVAI[i,11]
			oRMenor:SetFocus()
			oRMenor:Refresh()
			oDatIni:SetFocus()
			oDatIni:Refresh()
			odatFim:SetFocus()
			odatFim:Refresh()
			oTecVAI:SetFocus()
			
		ElseIf lAlter
			If !Empty(cRMenor)
				aTecVAI[i,9] := Strzero(val(cRMenor),2)
			EndIf
			
			If !Empty(dDatIni)
				aTecVAI[i,10] := dDatIni
			EndIf
			
			If !Empty(dDatFim)
				aTecVAI[i,11] := dDatFim
			EndIf
		EndIF
	Endif
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FILTRARบAutor  ณRafael Goncalves    บ Data ณ  02/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza o filtro                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_FILTRAR()
Local cQuery     := ""
Local cQueryTemp := ""
Local cQAlSQL    := "ALIASSQL"
Local cNomBco    := ""
Local _ni        := 0
Local _nj        := 0
Local lPrivez    := .t.
Local lFilt      := .f.
Local ni         := 0
Local cBkpFilAnt := cFilAnt
aTecVAI:= {}

For _ni := 1 to Len(aFiliais)
	IF aFiliais[_ni,01]
		lFilt := .t.
		Exit
	EndIF
Next
If lFilt
	lFilt:=.f.
	For _ni := 1 to Len(aTipGer)
		If aTipGer[_ni,01]
			lFilt := .t.
		EndIf
	Next
EndIF

If lFilt
	If Len(aFiliais) > 0
		For _ni := 1 to Len(aFiliais)
			If aFiliais[_ni,1] // se tiver filial ticada
				cFilAnt := aFiliais[_ni,2]
				cQuery := "SELECT VAI.VAI_FILIAL , VAI.VAI_NIVRET , VAI.VAI_NOMTEC , VAI.VAI_CODUSR , VAI.VAI_TIPVEI , VAI.VAI_ESTVEI , VAI.VAI_TIPTEC "
				cQuery += "FROM "+RetSqlName("VAI")+" VAI "
				cQuery += "WHERE VAI.VAI_FILIAL='"+xFilial("VAI")+"' AND VAI.VAI_CODUSR<>' ' AND "
				cQuery += "VAI.VAI_ESTVEI = '"+cEstVei+"' AND "
				cQuery += "VAI.VAI_TIPVEI = '"+cTipVei+"' AND "
				cQueryTemp := "( VAI.VAI_FILIAL='"+xFilial("VAI")+"'"
				If Len(aTipGer) > 0
					lPrivez:=.T.
					For _nj := 1 to Len(aTipGer)
						IF aTipGer[_nj,1]
							If lPrivez
								cQueryTemp += " AND VAI.VAI_TIPTEC IN ('"+LEFT(aTipGer[_nj,2],1)+"'"
								lPrivez:=.f.
							Else
								cQueryTemp += ",'"+LEFT(aTipGer[_nj,2],1)+"'"
							EndIF
						Endif
					Next
					If !lPrivez
						cQueryTemp += ")"
					EndIf
				EndIf
				cQueryTemp += ") AND "
				//adiciona no array
				cQueryTemp += "VAI.D_E_L_E_T_=' ' ORDER BY VAI.VAI_CODTEC"
				cQueryTemp := cQuery+cQueryTemp
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryTemp ), cQAlSQL , .F., .T. )
				While !( cQAlSQL )->( Eof() )
					ni := aScan(aFiliais,{|x| x[2] == cFilAnt })
					aAdd(aTecVAI,{.f.,( cQAlSQL )->( VAI_FILIAL ) ,; //FILIAL
										( cQAlSQL )->( VAI_TIPTEC ),; //TIPO GERENTE
										( cQAlSQL )->( VAI_ESTVEI ),; //ESTVEI
										( cQAlSQL )->( VAI_TIPVEI ),; //TIPVEI
										( cQAlSQL )->( VAI_CODUSR ),; //USUARIO
										( cQAlSQL )->( VAI_NOMTEC ),; //NOME TECNICO
										( cQAlSQL )->( VAI_NIVRET ),; //NIVEL RETORNO NORMAL
										"  ",; //( cQAlSQL )->( VNR_NIVRET )-NIVEL RETORNO MENOR
										ctod("  /  /  ") ,;//( cQAlSQL )->( VNR_DATINI )-VIGENCIA INICIAL
										ctod("  /  /  ") ,;//( cQAlSQL )->( VNR_DATFIN )-VIGENCIA FINAL
										IIf(ni>0," - "+aFiliais[ni,3],"") })//NOME DA FILIAL
					( cQAlSQL )->( DbSkip() )
				EndDo
				( cQAlSQL )->( dbCloseArea() )
				
			EndIf
			If Empty(xFilial("VAI")) // Quando VAI estiver compartilhado, mostrar Tecnico uma unica vez
				Exit
			EndIf
		Next
	EndIf
EndIf
cFilAnt := cBkpFilAnt

If Len(aTecVAI) <= 0
	aAdd(aTecVAI,{.f.," "," "," "," "," "," "," "," ",ctod(""),ctod(""),"" })
EndIf
oTecVAI:SetArray(aTecVAI)
oTecVAI:bLine := { || { IIf(aTecVAI[oTecVAI:nAt,01],oOk,oNo),;
						aTecVAI[oTecVAI:nAt,02]+aTecVAI[oTecVAI:nAt,12],;
						X3CBOXDESC("VAI_TIPTEC",aTecVAI[oTecVAI:nAt,03]),;
						X3CBOXDESC("VAI_ESTVEI",aTecVAI[oTecVAI:nAt,04]),;
						X3CBOXDESC("VAI_TIPVEI",aTecVAI[oTecVAI:nAt,05]),;
						aTecVAI[oTecVAI:nAt,06]+" - "+aTecVAI[oTecVAI:nAt,07],;
						aTecVAI[oTecVAI:nAt,08],;
						aTecVAI[oTecVAI:nAt,09],;
						aTecVAI[oTecVAI:nAt,10],;
						aTecVAI[oTecVAI:nAt,11] }}

Return

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ TIK dos ListBox de Filtro                                    ณ
//ณ Tipo 1 muda selecionado/2 muda todos                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TIK    บAutor  ณThiago				 บ Data ณ  10/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se existe filial selecionada                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TIK(cChamada,nLinha,nOpc,cTipo,lTipo)
Local _ni:=1
Local lLstGer := .f.
default cTipo := "1"
//If nOpc == 2 .or. nOpc == 5  //visualizar/excluir nao permite alterar
//	Return()
//EndIF
Do Case
	Case cChamada == "FIL"
		If cTipo="1"
			If len(aFiliais) > 1 .or. !Empty(aFiliais[1,2])
				aFiliais[nLinha,1] := !aFiliais[nLinha,1]
			EndIf
		Else
			For _ni := 1 to Len(aFiliais)
				aFiliais[_ni,01] := lTipo
			Next
		EndIf
		//valida se existe filial selecionada
		For _ni := 1 to Len(aFiliais)
			If aFiliais[_ni,01]
				lLstGer := .t.
				Exit
			EndIf
		Next
		If !lLstGer
			For _ni := 1 to Len(aTipGer)
				aTipGer[_ni,01] := .f.
				lTipVAI := .f.
			Next
		EndIf
	Case cChamada == "GER"
		For _ni := 1 to Len(aFiliais)
			If aFiliais[_ni,01]
				lLstGer := .t.
				Exit
			EndIf
		Next
		If lLstGer
			If cTipo="1"
				If len(aTipGer) > 1 .or. !Empty(aTipGer[1,2])
					aTipGer[nLinha,1] := !aTipGer[nLinha,1]
				EndIf
			Else
				For _ni := 1 to Len(aTipGer)
					aTipGer[_ni,01] := lTipo
				Next
			EndIf
		EndIf
	Case cChamada == "USU"
		If cTipo="1"
			If len(aTecVAI) > 1 .or. !Empty(aTecVAI[1,2])
				aTecVAI[nLinha,1] := !aTecVAI[nLinha,1]
			EndIf
		Else
			For _ni := 1 to Len(aTecVAI)
				aTecVAI[_ni,01] := lTipo
			Next
		EndIF
EndCase
oLbFil:Refresh()
oTpGer:Refresh()
oTecVAI:Refresh()
oCTipGer:Refresh()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOA670D    บAutor  ณRafael Goncalves    บ Data ณ  05/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExclusao                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OA670D(cAlias,nReg,nOpc)
If VNR->VNR_ATIVO="1"
	If MsgYesNo(STR0027,STR0019) // Deseja desativar? / Atencao
		DBSelectArea("VNR")
		RecLock("VNR", .F. )
		VNR->VNR_ATIVO  := "0"//0=Nao;1=Sim
		VNR->VNR_USUDEL := __cUserID
		VNR->VNR_DATDEL := dDataBase
		MsUnLock()
	EndIf
EndIF
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVA670NRET บAutor  ณRafael Goncalves    บ Data ณ  05/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o nivel de retorno do usuario informado.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VA670NRET(cFilUser,cCodUser,dDatInf)
Local cNivRet := ""
Local cQuery  := ""
Local cQAlSQL := "ALIASSQL"

Default cFilUser := xFilial("VAI")
Default cCodUser := __cUserID
Default dDatInf  := dDataBase

cQuery := "SELECT VNR.VNR_NIVRET "
cQuery += "FROM "+RetSqlName("VNR")+" VNR "
cQuery += "WHERE VNR.VNR_FILIAL='"+xFilial("VNR")+"' AND VNR.VNR_ATIVO='1'"
cQuery += " AND VNR.VNR_DATINI<='"+dtos(dDatInf)+"' AND VNR.VNR_DATFIN>='"+dtos(dDatInf)+"'"
cQuery += " AND VNR.VNR_FILUSU='"+cFilUser+"' AND VNR.VNR_USUARI='"+cCodUser+"'"
cQuery += " AND VNR.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
If !( cQAlSQL )->( Eof() )
	cNivRet := ( cQAlSQL )->( VNR_NIVRET )
EndIf
( cQAlSQL )->( dbCloseArea() )
DBSelectArea("VNR")

If Empty(cNivRet)
	cNivRet := FGX_USERVL(cFilUser,cCodUser,"VAI_NIVRET","?")
EndIf

Return(cNivRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณRafael Goncalves    บ Data ณ  05/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Menu													      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := {	{ STR0028 ,"AxPesqui", 0 , 1} ,;		// Pesquisar
					{ STR0029 ,"OA670I", 0 , 3},;			// Incluir
					{ STR0030 ,"OA670D", 0 , 4},;			// Desativar
					{ STR0031 ,"OA670LEG", 0 , 2,0,.f.}}	// Legenda
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOA670LEG  บAutor  ณRafael Goncalves    บ Data ณ  05/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Legenda												      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OA670LEG()
Local aLegenda := {	{'BR_VERDE'	,STR0032},; //Ativo
					{'BR_VERMELHO',STR0033}}  //Inativo
BrwLegenda(cCadastro,STR0031 ,aLegenda) //Legenda
Return .T.