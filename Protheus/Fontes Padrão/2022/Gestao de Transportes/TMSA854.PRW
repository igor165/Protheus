#Include "TMSA854.CH"
#Include "Protheus.ch"
#Include "FWMVCDEF.ch" 

Static aDoctos    := {}
Static aCachePerf := {}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA854 ³ Autor ³ Valdemar Roberto     ³ Data ³ 13.12.2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Seleciona Documentos Aleatórios para Faturamento           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA854                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSA854()
Local oMBrowse    := Nil

Private aRotina   := MenuDef()
Private cCadastro := STR0001	//-- "Documentos a Faturar"
Private nValFat   := 0
Private nQtdCTRC  := 0

oMBrowse:= FWMBrowse():New()
oMBrowse:SetAlias("SE1")
oMBrowse:SetDescription(cCadastro)
	
//-- Define os Status (Não alterar a ordem do AddLegend pois está respeitando as validações de Status como é feito no Tmsa850Leg)
oMBrowse:AddLegend( 'E1_SITFAT="3"'               , "BLACK"  , STR0018 ) // "Fatura Cancelada"
oMBrowse:AddLegend( 'ROUND(E1_SALDO,2) == ROUND(E1_VALOR,2) .and. E1_SITUACA $ "F6"', "YELLOW" , STR0019 ) // "Fatura Protestada."
oMBrowse:AddLegend( 'ROUND(E1_SALDO,2) = 0'       , "RED"    , STR0020   ) // Fatura Baixada"
oMBrowse:AddLegend( 'E1_SITFAT="2"'               , "BLUE"   , STR0021  ) // "Fatura Impressa"
oMBrowse:AddLegend( '.T.'                         , "GREEN"  , STR0022 ) // "Fatura em aberto"	

oMBrowse:SetCacheView(.F.) //-- Desabilita Cache da View, pois gera colunas dinamicamente
oMBrowse:Activate()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ModelDef   ³ Autor ³ Valdemar Roberto  ³ Data ³ 13.12.2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Define modelo para Faturas por Leitor                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ModelDef()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Private aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"		  OPERATION 1 ACCESS 0	//-- "Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "Tmsa850Vis"      OPERATION 2 ACCESS 0	//-- "Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TMSA854" OPERATION 3 ACCESS 0	//-- "Incluir"
ADD OPTION aRotina TITLE STR0015 ACTION "Tmsa850Exc"      OPERATION 5 ACCESS 0	//-- "Cancelar"
ADD OPTION aRotina TITLE STR0016 ACTION "Tmsa850Leg"      OPERATION 6 ACCESS 0	//-- "Legenda"

Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ModelDef   ³ Autor ³ Valdemar Roberto  ³ Data ³ 13.12.2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Define modelo para Faturas por Leitor                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ModelDef()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ModelDef()
Local oModel	:= Nil
Local oStruIDT6 := FwFormStruct(1,"DT6",{|x| AllTrim(x) $ "DT6_FILDOC,DT6_DOC,DT6_SERIE,DT6_CLIDEV,DT6_LOJDEV,DT6_NOMDEV,DT6_CHVCTE"})
Local oStruCDT6 := MdoStruW01(oStruIDT6)	//-- Estrutura do Model (Codigo de Barra)

aDoctos    := {}
aCachePerf := {}
nQtdCTRC   := 0
nValFat    := 0

oModel := MPFormModel():New("TMSA854",/*bPre*/,/*bPos*/,{|| TMA854Grv()},/*bCancel*/)
oModel:SetDescription(STR0001) //-- "Documentos a Faturar"

//-- Codigo de barras
oModel:AddFields("MdFieldCDT6",/*cOwner*/,oStruCDT6,/*bPre*/,/*bPost*/,/*bLoad*/)

oModel:SetPrimaryKey({"DT6_FILIAL","DT6_FILDOC","DT6_DOC","DT6_SERIE"})

//-- Documentos
oModel:AddGrid("MdGridIDT6","MdFieldCDT6" /*cOwner*/,oStruIDT6,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)

oModel:GetModel("MdGridIDT6"):SetUseOldGrid(.F.)
oModel:GetModel("MdGridIDT6"):SetNoInsertLine(.T.)
oModel:GetModel("MdGridIDT6"):SetNoUpdateLine(.T.)
oModel:GetModel("MdGridIDT6"):SetNoDeleteLine(.T.)

Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ViewDef    ³ Autor ³ Valdemar Roberto  ³ Data ³ 13.12.2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Define tela para Faturas por Leitor                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ViewDef()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ViewDef()
Local oModel 	:= FwLoadModel("TMSA854")
Local oView 	:= Nil
Local oStruIDT6 := FwFormStruct(2,"DT6",{|x| AllTrim(x) $ "DT6_FILDOC,DT6_DOC,DT6_SERIE,DT6_CLIDEV,DT6_LOJDEV,DT6_NOMDEV,DT6_CHVCTE"})
Local oStruCDT6 := VwoStruW01(oStruIDT6)	//-- Estrutura do Model - Codigo de Barra

oView := FwFormView():New()
oView:SetModel(oModel)

oView:CreateHorizontalBox("Superior",20)
oView:CreateHorizontalBox("Inferior",80)

oView:AddField("VwFieldCDT6",oStruCDT6,"MdFieldCDT6",,{|| SetaFoco()})

oView:AddGrid("VwGridIDT6",oStruIDT6,"MdGridIDT6",,{|| SetaFoco()})

oView:EnableTitleView("VwFieldCDT6",STR0007)	//-- "Chave do CTe"
oView:EnableTitleView("VwGridIDT6" ,STR0008)	//-- "Documentos de Transporte"

oView:SetOwnerView("VwFieldCDT6","Superior")
oView:SetOwnerView("VwGridIDT6" ,"Inferior")

oView:SetViewProperty("VwGridIDT6", "ENABLENEWGRID")

oView:SetCloseOnOk({|| .T.})
oView:SetViewAction("ASKONCANCELSHOW",{||.F.})
oView:ShowInsertMsg(.F.)

Return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MdoStruW01 ³ Autor ³ Valdemar Roberto  ³ Data ³ 13.12.2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta estrutura de Model do codigo de barras               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MdoStruW01()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MdoStruW01(oStruIDT6)
Local oStruW01 := FWFormModelStruct():New()
Local aIndex   := {1,"1","W01_CODBAR","Codigo de Barras"}

oStruW01:AddTable("W01",{"W01_CODBAR"},"Codigo de Barras")

oStruW01:AddIndex(aIndex[1],;	//-- [01] Ordem do indice
				  aIndex[2],;	//-- [02] ID
				  aIndex[3],;	//-- [03] Chave do indice
				  aIndex[4],;	//-- [04] Descrição do indice
				  ""       ,;	//-- [05] Expressão de lookUp dos campos de indice
				  ""       ,;	//-- [06] Nickname do indice
				  .T.)       	//-- [07] Indica se o indice pode ser utilizado pela interface   
			
oStruW01:AddField(STR0009,STR0009,"W01_CODBAR","C",TamSX3("DT6_CHVCTE")[1],0,{|| TMA854CBar(oStruIDT6)},,{},.F.,,.F.,.F.,.T.,,)

Return oStruW01

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VwoStruW01 ³ Autor ³ Valdemar Roberto  ³ Data ³ 13.12.2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta estrutura de Model do codigo de barras               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VwoStruW01()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VwoStruW01(oStruIDT6)
Local oStruW01 := FWFormViewStruct():New()

oStruW01:AddField("W01_CODBAR","01",STR0009,STR0009,,"G",Nil,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.)

Return oStruW01

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMA854CBar ³ Autor ³ Valdemar Roberto  ³ Data ³ 13.12.2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta estrutura de Model do codigo de barras               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA854CBar()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function TMA854CBar(oStruIDT6)
Local aAreas      := {DT6->(GetArea()),SA1->(GetArea()),GetArea()}
Local aPerfil     := {}
Local oModel      := FwModelActive()
Local oMdlGridDT6 := oModel:GetModel("MdGridIDT6")
Local cCodBarra   := PadR(AllTrim(oModel:GetModel("MdFieldCDT6"):GetValue("W01_CODBAR")),TamSx3("DT6_CHVCTE")[1])
Local lRet		  := .T.
Local lLinDel     := .T.
Local lContDoc    := SuperGetMv("MV_CONTDOC",.F.,.F.) .And. FindFunction("TmsConTran")
Local nLinha      := 0    
Local nCntFor1    := 0
Local nCntFor2    := 0
Local nPos        := 0
Local xValue

FwClearHLP()

oMdlGridDT6:SetNoDeleteLine(.F.)
oMdlGridDT6:SetNoUpdateLine(.F.)
oMdlGridDT6:SetNoInsertLine(.F.)


	DT6->(DbSetOrder(18))
	If !Empty(cCodBarra) .And. DT6->(DbSeek(xFilial("DT6") + cCodBarra))
		If !Empty(DT6->DT6_NUM)
			Help('',1,'HELP',,STR0011,03,00)
			lRet:= .F.	
		ElseIf !Empty(DT6->DT6_SERIE == "COL")
			//MsgAlert(STR0014,STR0012)	//--"Documento do tipo COLETA não pode ser faturado"
			Help('',1,'HELP',,STR0014,03,00)
			lRet:= .F.	
		Else
			If oMdlGridDT6:SeekLine({{"DT6_CHVCTE",cCodBarra}},.T.)
				If oMdlGridDT6:IsDeleted()

					If (nPos := Ascan(aCachePerf,{|x| x[1] + x[2] == DT6->(DT6_CLIDEV + DT6_LOJDEV)})) == 0
						aPerfil := TMSPerfil(DT6->DT6_CLIDEV,DT6->DT6_LOJDEV)
						Aadd(aCachePerf,{DT6->DT6_CLIDEV,DT6->DT6_LOJDEV,Iif(Empty(aPerfil),0,aPerfil[10]),Iif(Empty(aPerfil),0,aPerfil[11])})
						nPos := Len(aCachePerf)
					EndIf
					lRet := TMA850Val(.F.,@nValFat,lContDoc,@nQtdCTRC,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,;
									  DT6->DT6_VALFAT,DT6->DT6_ACRESC,DT6->DT6_DECRESC,,.T.,aCachePerf[nPos,3],aCachePerf[nPos,4],;
									  DT6->DT6_CLIDEV,DT6->DT6_LOJDEV,DT6->DT6_FILDEB,.T.)
					If lRet
						lRet := (T850FatBrc(.T.,cCodBarra,@aDoctos,.F.)) > 0
					EndIf
					If lRet
						aDoctos[Len(aDoctos),1] := .T.
						oModel:GetModel("MdGridIDT6"):UnDeleteLine()
					EndIf

				Else
					nLinha := Ascan(aDoctos, {|x| x[2] + x[3] + x[4] == DT6->(DT6_FILDOC + DT6_DOC + DT6_SERIE)} )
					If nLinha > 0
						Adel(aDoctos,nLinha)
						Asize(aDoctos,Len(aDoctos) - 1)
						oModel:GetModel("MdGridIDT6"):DeleteLine()
					EndIf
				
					//--Desbloquear em caso de reativar o que estava deletado
					If lContDoc .And. nLinha > 0
						TmsConTran(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE, .F.)
					EndIf

				EndIf
				oMdlGridDT6:GoLine(1)
			Else

				If (nPos := Ascan(aCachePerf,{|x| x[1] + x[2] == DT6->(DT6_CLIDEV + DT6_LOJDEV)})) == 0
					aPerfil := TMSPerfil(DT6->DT6_CLIDEV,DT6->DT6_LOJDEV)
					Aadd(aCachePerf,{DT6->DT6_CLIDEV,DT6->DT6_LOJDEV,Iif(Empty(aPerfil),0,aPerfil[10]),Iif(Empty(aPerfil),0,aPerfil[11])})
					nPos := Len(aCachePerf)
				EndIf
				lRet := TMA850Val(.F.,@nValFat,lContDoc,@nQtdCTRC,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,;
								  DT6->DT6_VALFAT,DT6->DT6_ACRESC,DT6->DT6_DECRESC,,.T.,aCachePerf[nPos,3],aCachePerf[nPos,4],;
								  DT6->DT6_CLIDEV,DT6->DT6_LOJDEV,DT6->DT6_FILDEB,.T.)
				If lRet
					lRet := (T850FatBrc(.T.,DT6->DT6_CHVCTE,@aDoctos,.F.)) > 0
				EndIf
				If lRet
					aDoctos[Len(aDoctos),1] := .T.
				EndIf

				If lRet
					If !Empty(oMdlGridDT6:GetValue("DT6_DOC",1))
						nLinha := oMdlGridDT6:AddLine()
						For nCntFor1 := oMdlGridDT6:Length() To 2 Step -1
							oMdlGridDT6:GoLine(nCntFor1 - 1)
							lLinDel := oMdlGridDT6:IsDeleted()
							oMdlGridDT6:GoLine(nCntFor1)
							For nCntFor2 := 1 To Len(oStruIDT6:aFields)
								xValue := oMdlGridDT6:GetValue(oStruIDT6:aFields[nCntFor2,3],nCntFor1 - 1)
								oMdlGridDT6:LoadValue(oStruIDT6:aFields[nCntFor2,3],xValue)
							Next nCntFor2
							If lLinDel
								oMdlGridDT6:DeleteLine()
								oMdlGridDT6:GoLine(nCntFor1 - 1)
								oMdlGridDT6:UnDeleteLine()
							EndIf
						Next nCntFor1
					EndIf
				
					oMdlGridDT6:GoLine(1)
			
					oMdlGridDT6:LoadValue("DT6_FILDOC",DT6->DT6_FILDOC)
					oMdlGridDT6:LoadValue("DT6_DOC"   ,DT6->DT6_DOC)
					oMdlGridDT6:LoadValue("DT6_SERIE" ,DT6->DT6_SERIE)
					oMdlGridDT6:LoadValue("DT6_CLIDEV",DT6->DT6_CLIDEV)
					oMdlGridDT6:LoadValue("DT6_LOJDEV",DT6->DT6_LOJDEV)
					oMdlGridDT6:LoadValue("DT6_NOMDEV",Posicione("SA1",1,xFilial("SA1") + DT6->(DT6_CLIDEV + DT6_LOJDEV),"A1_NOME"))
					oMdlGridDT6:LoadValue("DT6_CHVCTE",DT6->DT6_CHVCTE)
				EndIf
			EndIf
		EndIf
	Else
		oModel:GetModel():SetErrorMessage(,,,,,STR0010)	//-- "Documento não encontrado"
		lRet:= .F.
	EndIf

	If lRet
		nQtdCTRC := 0
		nValFat  := 0
		AEval(aDoctos,{|e| Iif(e[1],nQtdCTRC ++,NIL)},,)
		AEval(aDoctos,{|e| Iif(e[1],nValFat += e[8],NIL)},,)
	EndIf
	
oMdlGridDT6:SetNoDeleteLine(.T.)
oMdlGridDT6:SetNoUpdateLine(.T.)
oMdlGridDT6:SetNoInsertLine(.T.)

aEval(aAreas,{|xArea| RestArea(xArea)})

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ SetaFoco   ³ Autor ³ Valdemar Roberto  ³ Data ³ 18.12.2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Volta o foco                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SetaFoco()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SetaFoco()
Local oModel := FwModelActive()
Local oView  := FWViewActive()

If oView <> Nil
		oModel:GetModel("MdFieldCDT6"):LoadValue("W01_CODBAR",Space(TamSx3("DT6_CHVCTE")[1]))
		oView:Refresh()
		oView:GetViewObj("VwFieldCDT6")[3]:getFWEditCtrl("W01_CODBAR"):oCtrl:SetFocus() 
		oView:Refresh()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMA854Grv  ³ Autor ³ Valdemar Roberto  ³ Data ³ 18.12.2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravação                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA854Grv()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMA854Grv()
Local nCont	     := 0

Local aAreas     := {DT6->(GetArea()),GetArea()}
Local aPrm491QRY := {}
Local aPrmQry    := {}
Local aMsgErr    := {}
Local cNat       := ""
Local cNatRod    := ""
Local cNatAer    := ""
Local cNatFlu    := ""
Local nThreads   := SuperGetMv("MV_TMSTHRE",,0)
Local nLinha     := 0
Local lThread    := Iif(nThreads > 0,.T.,.F.)
Local lContDoc   := SuperGetMv("MV_CONTDOC",.F.,.F.) .And. FindFunction("TmsConTran")

If !TMSA491Nat(@cNat,@cNatRod,@cNatAer,@cNatFlu)
	MsgAlert(STR0013,STR0012) // "Problemas nas naturezas. Verifique.") ### "Atenção"
Else	
	DT6->(DbSetOrder(1))
	
	For nCont := 1 To Len(aDoctos)
		If DT6->(DbSeek(xFilial("DT6") + aDoctos[nCont,2] + aDoctos[nCont,3] + aDoctos[nCont,4]))
			If (nLinha := Ascan(aPrmQry,{|x| x[1] + x[2] + x[3] == DT6->(DT6_FILDEB + DT6_CLIDEV + DT6_LOJDEV)} )) == 0
				Aadd(aPrmQry,{DT6->DT6_FILDEB,DT6->DT6_CLIDEV,DT6->DT6_LOJDEV,1," "})
			Else
				aPrmQry[nLinha,4] ++
			EndIf
		EndIf
	Next nCont

	ASort(aPrmQry,,,{|x,y| x[1] + x[2] + x[3] < y[1] + y[2] + y[3]})


	TMSA491THR(.T.,cNat,cNatRod,cNatAer,cNatFlu,.T.,Aclone(aPrmQry),Aclone(aDoctos),@aMsgErr)

	If Len(aMsgErr) > 0
		TmsMsgErr( aMsgErr, STR0012 ) //"Atenção"
	EndIf

	If lContDoc
		For nCont := 1 To Len(aDoctos)
			TmsConTran(aDoctos[nCont,2],aDoctos[nCont,3],aDoctos[nCont,4],.F.)
		Next nCont
	EndIf
EndIf

aDoctos := {}

aEval(aAreas,{|x,y| RestArea(x)})

Return .T.
