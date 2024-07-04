#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWTABLEATTACH.CH"
#INCLUDE "FWCALENDARWIDGET.CH"
#INCLUDE "GPEW020.CH"

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEW020  � Autor � Flavio S Correa           � Data � 26/03/15 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � WorkArea - Admissao					                          ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � Gen�rico                                                       ���
�����������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                 ���
�����������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS/FNC �  Motivo da Alteracao                     ���
�����������������������������������������������������������������������������Ĵ��
���Flavio Corr �26/03/15�PCREQ-4161 �Inclusao Fonte			                  ���
���Flavio Corr �21/09/16�RHRH001-402�Ajustes de menu		                  ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/   
Function GPEW020(oObj,cTipo)

Default oObj	:= Nil
Default cTipo	:= 1 //1=grafico2=sem grafico

Private oBrwSRB
Private oBrwSRA
Private oBrwSRQ
Private lNovoCalc 	:= NovoCalcBEN() //utilizado no GPEA131

FWMsgRun(/*oComponent*/, { || WkAdmissao(oObj,cTipo ) }, "Aguarde", "Carregando �rea de Trabalho..." )		// "Aguarde"		"Carregando �rea de Trabalho..."

Return .T.


Function WkAdmissao(oObj,cTipo)

Local lFunc 	:= .F.
Local aMenu 	:= {}
Local cAliasTmp	:= ""
Local cRec		:= ""

Default oObj	:= Nil
Default cTipo	:= 1 //1=grafico2=sem grafico

If ValType( oObj ) == "O"
	oObj:Sair()
	oObj := Nil
EndIf

oObj := TRHWorkArea():New(STR0001)//"Area de Trabalho - Admiss�o"
//Menu
oMenu := oObj:LoadMenu(,cTipo)
aMnuAdm := aMnuAdm() //carrega menu da workarea admissao
oMenu := oObj:SetMenuRotina(oMenu,aMnuAdm)
oObj:SetMenu(oMenu)


//Layout
If cTipo == 1
	oObj:SetLayout({{"01",50,.F.},{"02",50,.F.},{"03",50,.T.},{"04",50,.F.},{"05",50,.F.}}) //layout da tela.
Else
	oObj:SetLayout({{"03",50,.T.},{"04",50,.F.},{"05",50,.F.},{"03",50,.T.}}) //layout da tela.
EndIf


//Graficos
If cTipo == 1
	cAliasTMP := GetNextAlias()

	//busca funcionarios admitidos no mes e funcionarios com afastamentos no mes
	BeginSql alias cAliasTmp
		SELECT SRA.R_E_C_N_O_ RECNO FROM %table:SRA% SRA
		INNER JOIN %table:SR8% SR8 ON R8_FILIAL = RA_FILIAL AND R8_MAT = RA_MAT AND SR8.%notDel%  AND ( (R8_DATAINI >= %exp:dtos(Firstdate(date()))% AND (R8_DATAFIM <=%exp:dtos(Lastdate(date()))% OR R8_DATAFIM = '')) )
		WHERE SRA.%notDel% 
		AND RA_FILIAL = %exp:xFilial("SRA")%
		UNION 
		SELECT SRA.R_E_C_N_O_ RECNO FROM %table:SRA% SRA
		WHERE RA_FILIAL=%exp:xFilial("SRA")%
		AND RA_ADMISSA BETWEEN %exp:dtos(Firstdate(date()))% AND %exp:dtos(Lastdate(date()))%
		AND SRA.%notDel% 
	EndSql
	cRec := ""
	While !(cAliasTmp)->(eOf())
		cRec += Alltrim(Str((cAliasTmp)->RECNO)) + ","
		(cAliasTmp)->(dbSkip())
	EndDo
	(cAliasTmp)->(dbCloseArea())
	
	If Len(cRec) > 1
		cRec := substr(cRec,1,len(cRec)-1)
	EndIf
	//esse primeiro grafico exige um filtro, entao qdo o resultado tem que ser vazio , for�amos um filtro  generico.
	oObj:SetWidget( oObj:getPanel("01"), "SRA", "GPEA010", MODE_CHART  ,IIf(Empty(cRec),"RA_MAT='?????'","R_E_C_N_O_ IN ( " + cRec + ")"),"")
	oObj:SetWidget( oObj:getPanel("02"), "SQS", "RSPA100", MODE_CHART  ,"","")
EndIf

//Browse
owidget := oObj:SetWidget( oObj:getPanel("03"), "SRA", "GPEA010", MODE_BROWSE  ,"",STR0020)//"Funcion�rios"
oBrwSra := owidget:GetBrowse() 
oBrwSra:ExecuteFilter()
oBrwSRB := oObj:SetBrowse( oObj:getPanel("04"), "SRB", 'GPEA020', STR0002/*"Dependentes"*/,ChkRh("GPEA020","SRB","1"),.T.,.T.,.T.)
oBrwSRQ := oObj:SetBrowse( oObj:getPanel("05"), "SRQ", 'GPEA280', STR0003/*"Benefici�rios"*/,ChkRh("GPEA280","SRQ","1"),.T.,.T.,.T.)

//Relacionamento Browse SRA / SRB
dbSelectArea("SRB")
oRelacRDMRD1:= FWBrwRelation():New()
oRelacRDMRD1:AddRelation( oBrwSRA  , oBrwSRB , { { 'SRB->RB_FILIAL','RA_FILIAL'}, { 'SRB->RB_MAT' , 'RA_MAT'  } } )
oRelacRDMRD1:Activate(oObj:getPanel("03"))

//Relacionamento Browse SRA / SRQ
dbSelectArea("SRQ")
oRelacRDMRD2:= FWBrwRelation():New()
oRelacRDMRD2:AddRelation( oBrwSRA  , oBrwSRQ , { {  'SRQ->RQ_FILIAL','RA_FILIAL'}, { 'SRQ->RQ_MAT' , 'RA_MAT'  } } )
oRelacRDMRD2:Activate(oObj:getPanel("03"))

oObj:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} aMnuAdm()
Menu lateral da WorkArea - Admissao


@author Flavio Scalzaretto Correa
@since 26/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function aMnuAdm()
Local aMenu := {}

/*
01 - Pasta
02 - Descricao
03 - Bloco
04 - Rotina
05 - Modulo
*/
aadd(aMenu,{STR0004,{}})//"Admiss�o"
aadd(aMenu[Len(aMenu)][2],{STR0005,{|| RSPM001(),oBrwSRA:Refresh() },"RSPM001",20})//"+ Admiss�o"
aadd(aMenu[Len(aMenu)][2],{STR0006,{|| Gpea010Mnt("SRA" ,  , 3 , SRA->RA_MAT),FLimpaFilt(),SRA->(DbGoTop()),oBrwSRA:Refresh()},"GPEA010",7})//"+ Funcion�rios"
aadd(aMenu[Len(aMenu)][2],{STR0007,{|| FWExecView(STR0009 , "VIEWDEF.GPEA020", MODEL_OPERATION_UPDATE, , { || .T. } ),oBrwSRA:Refresh(),oBrwSRB:Refresh()},"GPEA020",7})//"+ Dependentes" / "Atualizar"
aadd(aMenu[Len(aMenu)][2],{STR0008,{|| GP280ATU("SRA",0,3),oBrwSRA:Refresh(),oBrwSRQ:Refresh() },"GPEA280",7})//"+ Benefici�rios"

aadd(aMenu,{STR0010,{}})//"Plano de Saude"
aadd(aMenu[Len(aMenu)][2],{STR0011,{|| FWExecView( STR0016, "VIEWDEF.GPEA001", MODEL_OPERATION_UPDATE, , { || .T. } )},"GPEA001",7})//"Incluir" //"Planos Ativos"


If lNovoCalc
	aadd(aMenu,{STR0021,{}})//"Beneficios"
	aadd(aMenu[Len(aMenu)][2],{STR0009,{|| FWExecView( STR0009, "VIEWDEF.GPEA133", MODEL_OPERATION_UPDATE, , { || .T. } )},"GPEA131",7})// "Atualizar"
Else
	aadd(aMenu,{STR0012,{}})//"Vale Refei��o"
	aadd(aMenu[Len(aMenu)][2],{STR0011,{|| GP131ATU("SRA",0,3,1),FLimpaFilt()},"GPEA131",7})//"Incluir"
	aadd(aMenu[Len(aMenu)][2],{STR0009,{||GP131ATU("SRA",SRA->(Recno()),4,1),FLimpaFilt()},"GPEA131",7})// "Atualizar"
	
	aadd(aMenu,{STR0013,{}})//"Vale Alimenta��o"
	aadd(aMenu[Len(aMenu)][2],{STR0011,{|| GP131ATU("SRA",0,3,2),FLimpaFilt()},"GPEA131",7})//"Incluir"
	aadd(aMenu[Len(aMenu)][2],{STR0009,{||GP131ATU("SRA",SRA->(Recno()),4,2),FLimpaFilt()},"GPEA131",7})// "Atualizar"
	
	aadd(aMenu,{STR0014,{}})//"Vale Transporte"
	aadd(aMenu[Len(aMenu)][2],{STR0015,{|| FWExecView(STR0011 , "VIEWDEF.GPEA140", MODEL_OPERATION_INSERT, , { || .T. } )},"GPEA140",7})//"Meios Transporte" // "Incluir"
	aadd(aMenu[Len(aMenu)][2],{STR0011,{|| GP131ATU("SRA",0,3,0),FLimpaFilt()},"GPEA131",7})//"Incluir"
	aadd(aMenu[Len(aMenu)][2],{STR0009,{|| GP131ATU("SRA",SRA->(Recno()),4,0),FLimpaFilt()},"GPEA131",7})// "Atualizar"
EndIf
aadd(aMenu,{STR0018,{}})//"Outros Beneficios"
aadd(aMenu[Len(aMenu)][2],{STR0009,{|| FWExecView( STR0009, "VIEWDEF.GPEA065", MODEL_OPERATION_UPDATE, , { || .T. } )},"GPEA065",7})// "Atualizar"

If ExistBlock("GPEWORD")
	aadd(aMenu,{STR0019,{}})//"Contratos"
	aadd(aMenu[Len(aMenu)][2],{STR0019,{|| ExecBlock("GPEWORD")},"GPEWORD",7})//"Contratos"
else
	aadd(aMenu,{STR0019,{}})//"Contratos"
	aadd(aMenu[Len(aMenu)][2],{STR0019,{|| GPER987()},"GPER987",7})//"Contratos"
EndIf

Return aMenu

Static Function FLimpaFilt()
	dbSelectArea("SRA")
	Set Filter To
Return
