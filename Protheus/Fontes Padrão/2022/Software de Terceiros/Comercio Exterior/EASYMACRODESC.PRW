#include 'protheus.ch'
#Include "MsObject.ch"
#Include "Average.ch"
#Include "EASYMACRODESC.CH"
#Define ENTER CHR(13)+CHR(10)


/*
Programa        : EASYMACRODESC.PRW
Objetivo        : Permitir que os campos memos sejam editados por macros
Autor           : Clayton Reis Fernandes
Data/Hora       : 11/01/2011 09:00   
Obs.            : Totalmente orientado a objetos. Contem 2 classes EASYMACRODESC e EASYMACROLIST
*/  

Function EasyMacroDesc(); Return Nil

Class EasyMacroList

   Data aMacros // Variavel para os objetos da macros
   Data cTitulo // Varival para o titudo da janela

   Method New() Constructor
   Method Add(cAlias, cChave, cFieldDesc, aAlias) // Instancia um objeto da classe EASYMACRODESC
   Method AddButton(aButtons) // Adiciona um botao em algum objeto
   Method List() // Frame
   Method RetCampos() // Carregar o conteúdo do combo da capa
   Method SaveMacro()// Salva as Macros na tabela
   Method ExcluiMacro()
   
End Class

Method New(cTitulo) Class EasyMacroList

   Self:aMacros := {}
   Self:cTitulo := cTitulo

Return Self

//Criação dos objetos da classe EasyMacroDesc
Method Add(cAlias, cChave, cFieldDesc, aAlias) Class EasyMacroList
Local oMacro := EasyMacroDesc():New(cAlias, cChave, cFieldDesc, aAlias)
   aAdd(Self:aMacros, oMacro)   
Return Nil

//Adição de botoes em algum objeto
//                  array, validação,imagem do botão
Method AddButton(aButtons, cCondicao,cImageButton) Class EasyMacroList
	If ValType(aButtons) == "A"
	  If Empty(cImageButton)
         cImageButton := "MPWIZARD"
      EndIf
      aAdd(aButtons, {cImageButton,&(cCondicao), STR0001, STR0001})//"Descrição dos itens"   

	EndIf                                   
Return Nil

//Edição do combo da capa
Method RetCampos() Class EasyMacroList
Local aCampos := {}
Local nInc
   For nInc := 1 To Len(Self:aMacros)
      aAdd(aCampos, Self:aMacros[nInc]:cFieldName)
   Next
Return aCampos

//Criação da lista
Method List() Class EasyMacroList

Local oDlg 
Local oList
Local oMemo
Local oPanel
Local oMacro
Local oFont
Local aCampos := Self:RetCampos() // campos do ComboCapa
Local cCampo  := ""
Local lOK     := .F.
Local nPos    := 1
Local i       := 1

   /** Janela para o combo Box*///   
   DEFINE MSDIALOG oDlg TITLE Self:cTitulo FROM 0,0 TO 390,620 PIXEL

      oPanel      := tPanel():New(1,1,"",oPanel,,,,,,310,200) // cria o painel
      @ 03,129 SAY  STR0002  Size 140,70  OF oPanel PIXEL //A macro de qual campo deseja criar?
      
      oComboCapa  := tComboBox():New(02,225,{|u|if(PCount()>0,cCampo:=u,cCampo)},;
                     aCampos,85,20,oPanel,,{|| Self:aMacros[oComboCapa:nAt]:Edit(oComboMacro, oList, oMemo)},,,,.T.,,,,,,,,,'cCampo')

      oComboMacro := tComboBox():New(19,225,{|u|if(PCount()>0,cCampo:=u,cCampo)},,85,20,oPanel,,;
                     {|| Self:aMacros[oComboCapa:nAt]:CarregaList(oList, oComboMacro:aItems[oComboMacro:nAt])},,,,.T.,,,,,,,,,'cCampo')
      oComboMacro:Hide()
      oComboMacro:Refresh()
      oComboMacro:Show()

      oList:= tListBox():New(35,225,,,84,144,,oPanel,,,,.T.,,;
                        {|| Self:aMacros[oComboCapa:nAt]:AddCampo(Self:aMacros[oComboCapa:nAt]:aListaItems[oList:nAt])},)
      oList:Hide()
      Self:aMacros[oComboCapa:nAt]:Edit(oComboMacro,oList)
      oList:Refresh()
      oList:Show()

      @ 35,1 Get oMemo Var Self:aMacros[oComboCapa:nAt]:cMacro MEMO HSCROLL FONT oFont Size 221,144  Of oPanel  Pixel
      oMemo:Hide()
      oMemo:Refresh()
      oMemo:Show()
      
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
 
   ACTIVATE MSDIALOG oDlg CENTER ON INIT (EnchoiceBar(oDlg,{||lOk:=.T.,oDlg:End()},{||oDlg:End()}))

   If lOk .And. MsgYesNo(STR0003,"Aviso") //Confirma atualizar todos os campos com a tradução da macro?
      For i:= 1 To Len(Self:aMacros)
         Self:aMacros[i]:AtuField()
      Next   
   EndIf

Return Self:aMacros[nPos]

Method SaveMacro(cChave) Class EasyMacroList

Local lSeek := .T.
Local i := 0

For i:= 1 To Len(Self:aMacros)

   If ValType(cChave) == "C" .And. !Empty(cChave)
      Self:aMacros[i]:cChave := cChave 
   EndIf

   EWX->(DbSetOrder(1))
   lSeek := EWX->(DbSeek(AvKey(xFilial(Self:aMacros[i]:cAlias),"EWX_FILIAL")+AvKey(Self:aMacros[i]:cAlias,"EWX_ALIAS")+AvKey(Self:aMacros[i]:cFieldDesc,"EWX_CAMPO")+AvKey(Self:aMacros[i]:cChave,"EWX_CHAVE")))
   If RecLock("EWX",!lSeek)
      EWX->EWX_FILIAL := xFilial(Self:aMacros[i]:cAlias)
      EWX->EWX_ALIAS  := Self:aMacros[i]:cAlias
      EWX->EWX_CAMPO  := Self:aMacros[i]:cFieldDesc
      EWX->EWX_CHAVE  := Self:aMacros[i]:cChave
      If !Empty(EWX->EWX_COD_MA)
         MSMM(EWX->EWX_COD_MA,,,,EXCMEMO)
      EndIf
      EWX->(MSMM(EWX->EWX_COD_MA,AVSX3("EWX_MACRO",AV_TAMANHO),,Self:aMacros[i]:cMacro,INCMEMO,,,"EWX","EWX_COD_MA"))
      EWX->(MsUnLock())
   EndIf
Next

Return Nil

Method ExcluiMacro() Class EasyMacroList
        
Local i := 0

For i:= 1 To Len(Self:aMacros)

   EWX->(DbSetOrder(1))
   If EWX->(DbSeek(AvKey(xFilial(Self:aMacros[i]:cAlias),"EWX_FILIAL")+AvKey(Self:aMacros[i]:cAlias,"EWX_ALIAS")+AvKey(Self:aMacros[i]:cFieldDesc,"EWX_CAMPO")+AvKey(Self:aMacros[i]:cChave,"EWX_CHAVE")))
      If RecLock("EWX",.F.)
         If !Empty(EWX->EWX_COD_MA)
            MSMM(EWX->EWX_COD_MA,,,,EXCMEMO)
         EndIf
         EWX->(dbDelete())
      EWX->(MsUnLock())
      EndIf
   EndIf
Next

Return Nil





Class EasyMacroDesc

	Data cMacro // Macro do campo Memo
	Data aComboItems // Vetor do combo da macro
	Data aListaItems  // Vetor de campos da lista
	Data cMascara // Mascara da macro
	Data cTagCampo // Identificador da macro
	Data cDivCampo // Variavel para separação do titulo do campo e o campo tecnico
    Data cAlias
    Data cChave // Chave da tabela EWX
    Data cFieldDesc // Nome do campo Memo
    Data cFieldMacro // Retorno da macro
    Data cFieldName // Nome que será apresentado no combo

	Method New(cAlias, cChave, cFieldDesc) Constructor
	Method Edit()
	Method CarregaList()
	Method AddAlias()
	Method AddCampo(cCampo)
	Method SetMascara(cMascara)
	Method RetMascara()
	Method SetTagCampo(cTag)
	Method RetTagCampo()
	Method Translate()
	Method SetField(cAlias, cFieldDesc, cFieldMacro)
	Method RetFieldDesc()
//	Method RetFieldMacro()
	Method AtuField()
//	Method RecordMacro()
	Method LoadMacro()
	Method SetCombo(aCombo)

End Class

Method New(cAlias, cChave, cFieldDesc,aAlias) Class EasyMacroDesc
Default := ""

	Self:aComboItems:= aAlias
	Self:aListaItems:= {}   
	Self:cMacro     := ""
    Self:cDivCampo  := "/"
    Self:SetMascara("#CAMPO $#")
	Self:SetTagCampo("$")
	Self:SetField(cAlias, cChave, cFieldDesc)
 //	If !Empty(Self:RetFieldMacro())
    Self:LoadMacro()
 //   EndIf
Return Self 

//Configurando o objeto da classe EasyMacroDesc
Method SetField(cAlias, cChave, cFieldDesc) Class EasyMacroDesc

   If ValType(cAlias) == "C" .And. !Empty(cAlias)
      Self:cAlias      := cAlias
      Self:cChave      := cChave
      Self:cFieldDesc  := cFieldDesc
      Self:cFieldName  := AvSx3(Self:cFieldDesc, AV_TITULO)

      EWX->(DbSetOrder(1)) // EWX_FILIAL + EWX_ALIAS + EWX_CAMPO + EWX_CHAVE
      If EWX->(DbSeek(AvKey(xFilial(cAlias),"EWX_FILIAL")+AvKey(cAlias,"EWX_ALIAS")+AvKey(cFieldDesc,"EWX_CAMPO")+AvKey(cChave,"EWX_CHAVE")))
         Self:cFieldMacro := MSMM(EWX->EWX_COD_MA,AVSX3("EWX_MACRO",AV_TAMANHO))
      Else 
         Self:cFieldMacro := ""
      EndIf

   EndIf

Return Nil


//Retorna a macro para ser editada.
Method LoadMacro() Class EasyMacroDesc

If EMpty(Self:cFieldMacro)
   Self:cMacro := ""
Else
   Self:cMacro := Self:cFieldMacro
EndIf
  /* If !Empty(Self:RetFieldMacro())
      Self:cMacro := &(Self:RetFieldMacro())
   EndIf
    */
Return Nil

//Retorna a informação do campo memo da Memoria da tabela escolhida.
Method RetFieldDesc() Class EasyMacroDesc
Local cRet := ""

   If ValType(Self:cFieldDesc) == "C" .And. !Empty(Self:cFieldDesc)
      cRet := Self:cAlias + "->" + Self:cFieldDesc
   EndIf

Return cRet

//Retorna a informação da macro.
/*Method RetFieldMacro() Class EasyMacroDesc
Local cRet := ""

   If ValType(Self:cFieldMacro) == "C" .And. !Empty(Self:cFieldMacro)
      cRet := Self:cAlias + "->" + Self:cFieldMacro
   EndIf                       	

Return cRet
*/
Method AtuField() Class EasyMacroDesc
   
   &(Self:RetFieldDesc())  := Self:Translate()

Return Nil


Method SetMascara(cMascara) Class EasyMacroDesc

   If ValType(cMascara) == "C" .And. !Empty(cMascara)
      Self:cMascara := cMascara
   EndIf

Return Self:cMascara

Method RetMascara() Class EasyMacroDesc
Return Self:cMascara

Method SetTagCampo(cTag) Class EasyMacroDesc

   If ValType(cTag) == "C" .And. !Empty(cTag)
      Self:cTagCampo := cTag
   EndIf

Return Self:cTagCampo

Method RetTagCampo() Class EasyMacroDesc
Return Self:cTagCampo


/*
==============================================================
* Autor : CRF - 19/01/11
============================================================
*/	
Method Edit(oCombo, oList, oMemo) Class EasyMacroDesc
Local oCombo := oCombo
Local oList  := oList

 oCombo:aItems := Self:SetCombo(Self:aComboItems)
 oList:aItems  := Self:CarregaList(oList, Self:aComboItems[1][1])

Return Nil

/*
=================================================
Autor : CRF - 19/01/11
==============================================
*/
Method AddAlias(aItens) Class EASYMACRODESC

If ValType(aItens)== "A"
  Self:aComboItems := aItens
EndIf

Return Self

/*
=================================================
Autor : CRF - 19/01/11
==============================================
*/

Method AddCampo(cCampo) Class EASYMACRODESC
Local cMacro := ""

  // Cria Fonte para visualização
  oFont := TFont():New('Courier new',,-18,.T.)
  cMacro := StrTran(Self:RetMascara(), Self:RetTagCampo(), cCampo)
  Self:cMacro += cMacro

Return Self

/*
==================================================================
* Autor    : CRF - 19/01/11
* Objetivo : Transformar o conteúdo das tags em em Informações
==================================================================
*/
Method Translate() Class EasyMacroDesc
Local cMacro := Self:cMacro
Local cMacroBK := cMacro
Local nLenID := 7
Local cID := "#CAMPO "   
Local cAliOri := "" //LRS 

If Valtype(cMacro) <> "C"
   cMacro := ""
EndIf

While At("#CAMPO", cMacro) > 0 // quer dizer que ele achou a expressão.

   nPos1 := At("#CAMPO", cMacro)

   nPos2 := At("#", SubStr(cMacro, nPos1 + nLenID))
   
   If nPos2 == 0
      MsgInfo(STR0004)//Erro na expressão
      cMacro := cMacroBK
      Exit
   Else
      If SubStr(cMacro, nPos1, nLenID) != cID
         MsgInfo(STR0004)//Erro na expressão
         cMacro := cMacroBK
      EndIf
   EndIf
  
   //LRS 27/06/2014 - Casos que o cMacro vai ter mais de um cDivCampo na separação da descrição/Campo
   If cMacro == "#CAMPO No. L/C/EEC_LC_NUM#"
      	cMacro:= "#CAMPO No. LC/EEC_LC_NUM#" 
      	
   ElseIF cMacro == "#CAMPO Dt.Sol.L/C/EEC_SL_LC#"
      	cMacro:= "#CAMPO Dt.Sol.LC/EEC_SL_LC#" 
      	
   ElseIF cMacro == "#CAMPO GE/DE/RE/Vn./EEC_GEDERE#"
      	cMacro := "#CAMPO GE-DE-RE-Vn./EEC_GEDERE#"
      	
   ElseIF cMacro == "#CAMPO DI/RI/Vinc./EEC_DIRIVN#"
      	cMacro := "#CAMPO DI-RI-Vinc./EEC_DIRIVN#" 
      	
   ElseIF cMacro == "#CAMPO Nr.Voo/Viag./EEC_VIAGEM#"
      	cMacro := "#CAMPO Nr.Voo-Viag./EEC_VIAGEM#"
          
   ElseIF cMacro == "#CAMPO CCPTC/CCROM/EEC_PTCROM#"
      	cMacro := "#CAMPO CCPTC-CCROM/EEC_PTCROM# "
   EndIf
   
   cTag := SubStr(cMacro, nPos1, nPos2 + nLenID)                                           
   
   cAux1 := SubStr(cTag,At(Self:cDivCampo,cTag)+1,10)
   If "#"$cAux1
      cCampo := SubStr(cAux1,1,At("#",cAux1)-1)
   Else
      cCampo := cAux1
   EndIf
   
   cAlias  := SubStr(cCampo,1,At("_",cCampo)-1)
   If Len(cAlias) == 2
      cAlias := "S" + cAlias
   EndIf
   
   If (nPos := aScan(Self:aComboItems, {|x| x[1] == cAlias })) > 0
      cAliOri := Self:aComboItems[nPos][2]
   EndIf
 
   If ValType(&(cAliori+"->"+cCampo)) = "C" 
      cMacro := StrTran(cMacro, cTag,  &(cAliori + "->" + cCampo))
   ElseIf ValType(&(cAliori+"->"+cCampo)) = "D"
      cMacro := StrTran(cMacro, cTag,  DToC(&(cAliori + "->" + cCampo)))
   ElseIf ValType(&(cAliori+"->"+cCampo)) = "N"
      cMacro := StrTran(cMacro, cTag,  Str(&(cAliori + "->" + cCampo)))
   EndIf
    
EndDo

Return cMacro

/*
==============================================================
* Autor    : CRF - 19/01/11
* Objetivo : Alimentará o objeto tListBox com as
             Informações tiradas do comboBox das Alias
==============================================================
*/
Method CarregaList(oList, cAlias) Class EASYMACRODESC
Local nPos := 0
Local cAliOri := ""
   
   SX3->(DbSetOrder(1))
   SX3->(DbSeek(cAlias))

   If (nPos := aScan(Self:aComboItems, {|x| x[1] == cAlias })) > 0
      cAliOri := Self:aComboItems[nPos][2]
   EndIf
   
   Self:aListaItems := {}
   
    While SX3->(!Eof()) .And. cAlias == SX3->X3_ARQUIVO 
       If SX3->X3_CONTEXT != "V" .And. X3Uso(SX3->X3_USADO)
        //  cCampo := SX3->X3_CAMPO 
          If (cAliOri) == "M"
             If ValType(&(cAliori+"->"+SX3->X3_CAMPO)) == "U" 
                SX3->(dbSkip())
                Loop
             EndIf
          Else
             If (cAliOri)->(FieldPos(SX3->X3_CAMPO)) == 0
                SX3->(dbSkip())
                Loop
             EndIf
          EndIf
         // If X3Uso(SX3->X3_USADO)//!(SX3->X3_USADO == NAO_USADO) 
             aAdd(Self:aListaItems,AllTrim(SX3->X3_TITULO)+Self:cDivCampo+AllTrim(SX3->X3_CAMPO))
         // EndIf
       EndIf
       SX3->(dbSkip())
   End

   If Valtype(oList) == "O"
      oList:aItems := Self:aListaItems
   EndIf
   aItems := Self:aListaItems

Return aItems

Method SetCombo(aCombo) Class EASYMACRODESC

Local i    := 1
Local aRet := {}

For i:=1 To Len(aCombo)
    aAdd(aRet,aCombo[i][1])
Next

Return aRet  

