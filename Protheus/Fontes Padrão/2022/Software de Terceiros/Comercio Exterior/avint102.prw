#include "AVERAGE.CH"
#include "XMLXFUN.CH"
#include "AVINT102.CH"

#Define EXT_XML		".xml"
#Define XML_ISO_8859_1 "<?xml version='1.0' encoding='ISO-8859-1' ?>"

#DEFINE __LASTERROR Errorblock(__aErrorBlock[Len(__aErrorBlock)])

#xTranslate TRY => (__lCatch:=.F.,__oError := NIL, If(!Type("__aErrorBlock")=="A",__aErrorblock:={},),;
                        aAdd(__aErrorblock,;
                        ErrorBlock({|e| if(__lCatch,(aDel(__aErrorBlock,Len(__aErrorBlock)),aSize(__aErrorBlock,Len(__aErrorBlock)-1)),),;
                                        __oError := e,;
                                        Break(e)})),;
                       );BEGIN SEQUENCE

#xcommand CATCH [<uVar>] => RECOVER;(__LASTERROR,__lCatch := .T., [<uVar> := If(ValType(__oError) == "O", __oError, NIL)])

#DEFINE _ENDTRY END SEQUENCE;(__lCatch:=.F.,__LASTERROR,aDel(__aErrorBlock,Len(__aErrorBlock)),aSize(__aErrorBlock,Len(__aErrorBlock)-1))

#xTranslate ENDTRY => _ENDTRY
#xTranslate END TRY => _ENDTRY

/*
Programa   : AvInt102.prw
Objetivo   : Re�ne as classes EasyLink e EasyLinkLog
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Obs        : 
*/

/*
Classe      : EasyLink
Objetivos   : Fazer a leitura e tradu��o de arquivos XML de servi�os.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     : 
Obs.        : 
*/
*=============*
Class EasyLink
*=============*

//*** Informa��es do servi�o
Data cInt
Data cAction
Data cService
Data cDir
Data cFile
//***

//*** Informa��es da contrata��o
Data dData
Data cHora
//***

//*** �reas de dados tempor�rias
Data aFilesExt //Armazena os arquivos XML externos utilizados no servi�o durante a tradu��o
Data aTempMem  //Aloca vari�veis que n�o podem ser armazenadas na propriedade "TEXT" das tags (Ex. Objetos)
//***

//*** Controle de mensagens de erro e avisos
Data cError
Data cWarning
//***

//*** Controles da estrutura do layout do servi�o
Data lOkStruct
Data lExtOpened
Data aAtts
Data aAuxAtts
Data aCmds
Data lInsertFields
//***

//*** Armazena o layout do servi�o (XML) quando carregado na mem�ria
Data oService
//***

//*** Controla as estruturas de repeti��o
Data nWhile
Data nFor
Data aForVars
Data lLoop
Data lExit
//***

//*** Aloca dados tempor�ios criados pelo layout do XML
Data aVars
//***

//***
Method New(cInt, cAction, cService, cNomXml, dData, cHora) Constructor
//***

//*** M�todos utilizados na abertura do layout do servi�o e de arquivos XML externos
Method __ReadXML()
Method OpenExtRef(cFile)
Method __XMLJoin(cFileFrom, cFileTo)
//***

//***  M�todos utilizados na leitura do layout e busca das defini��es das tags no dicion�rio de tags
Method ReadService(oXML)
Method ChkStructure(oTag, lSetNodPai)
Method SetAtributes(oTag)
Method GetDicProps(oTag)
//***

//*** M�todos utilizados para busca de tags e/ou conte�do e defini��es das mesmas
Method NodInf(oNod, cInf)
Method SearchNod(cNod, cRet, oNod, lSearchAll, _nNivel, _nNivelMax, cAtt, cType, __aNod)
Method Split(cNodes)
Method RetContent(oTag)
Method BackupNod(oNod, oBackup, lRemoveControls, lCopyRoot, aNotCopy, lValidAll, __nNivel)
Method ChkInfo(oNod)
//***

//*** M�todos utilizados na tradu��o do conte�do do layout
Method Translate(oXML)
Method TranslNod(oNod)
Method SetEspData(oNod, oStartTag)
Method GetIntData(cNodSearch, cAttSearch, oStartTag, cTag)
Method GetExtData(cNodSearch, cAttSearch, cTag)
Method AlocTempMem(xData)
Method TranslCmd(oNod)
Method TranslEstr(oNod, lRepl)
Method TagReplace(oNod, cAlias)
//***

//*** M�todos auxiliares na aloca��o de dados na mem�ria no conte�do do layout
Method NewVar(cVar, xData)
Method SetVar(cVar, xData)
Method RetVar(cVar)
//***

//*** M�todos utilizados no envio e recebimento das informa��es traduzidas
Method Send()
Method Receive()
Method RetMsg()
//***

End Class


/*
M�todo      : New
Classe      : EasyLink
Par�metros  : cInt, cAction, cService, cNomXml, dData, cHora
Retorno     : Self
Objetivos   : Retornar uma nova inst�ncia da classe EasyLink.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/ 
Method New(cInt, cAction, cService, cNomXml, dData, cHora) Class EasyLink
Default cService := ""
Default dData := Date()
Default cHora := Time()

::cDir := EasyGParam("MV_AVG0135",,"\XML")

// PLB 14/08/07 - Acerta Diretorio
If IsSrvUNIX()
   ::cDir := AllTrim(Lower(StrTran(::cDir, '\', '/')))
EndIf

::cInt      := cInt
::cAction   := cAction
::cService  := cService
If !Empty(cNomXML) .And. !At(".APH", Upper(cNomXML)) > 0//RMD - 16/01/15 - Possibilita a grava��o do XML em um arquivo APH
   If IsSrvUNIX()
      ::cFile := ::cDir + "/" + cNomXml
      ::cFile := AllTrim(Lower(::cFile))
   Else
      ::cFile := ::cDir + "\" + cNomXml
   EndIf
Else
   ::cFile := cNomXML
EndIf
::dData      := dData
::cHora      := cHora
::cError     := ""
::cWarning   := ""
::lOkStruct  := .F.
::lExtOpened := .F.
::aFilesExt  := {}
::aTempMem   := {}
::nWhile     := 0
::nFor       := 0
::aForVars   := {}
::lLoop      := .F.
::lExit      := .F.
::lInsertFields := .F.
::aAtts      := {"TYPE", "SIZE", "DECIMAL", "PICTURE", "AS"}
::aAuxAtts   := {"COND", "INI", "TO", "VAR", "STEP", "REPL", "ELINKINFO"}
::aCmds      := {"IF", "ALIAS", "ORDER", "SEEK", "WHILE", "SKIP", "EXIT", "FOR", "LOOP", "INSERT_FIELDS"}
::aVars      := {}
   
Return Self


/*
M�todo      : ReadService
Classe      : EasyLink
Par�metros  : oXML - Opcional - Objeto XML onde ser� feita a leitura. Por padr�o, l� o arquivo XML definido nas propriedades do servi�o
Retorno     : lRet - Indica se a leitura foi conclu�da
Objetivos   : Faz a leitura do arquivo XML do servi�o e verifica sua estrutura
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/ 
Method ReadService(oXML) Class EasyLink
Local lRet := .T.
Local nFound := 0, nInc
Local cTipo, cID
Default oXML   := ::__ReadXML()

Begin Sequence

   If !Empty(::cError)
      ::cError := STR0004 + ENTER;//"N�o foi poss�vel ler o arquivo XML do servi�o."
                  + STR0005 + ::cError//"Erro encontrado:"
      lRet := .F.
      Break
   EndIf
   
   If !(::SearchNod("SERVICE",, oXML:_EASYLINK))
      ::cError := STR0004 + ENTER;//"N�o foi poss�vel ler o arquivo XML do servi�o."
                  + STR0006 + ::cError//"Foram encontrados erros na estrutura do XML."
      lRet := .F.
      Break
   EndIf
   
   //Verifica se o arquivo XML possui um ou mais servi�os
   cTipo := ValType(::SearchNod("SERVICE", "Self", oXML:_EASYLINK))
   If cTipo == "A"
      For nInc := 1 To Len(oXML:_EasyLink:_SERVICE)
         If ValType(oXML:_EasyLink:_SERVICE[nInc]) == "O" .And. ;
            ::SearchNod("ID", "Self", oXML:_EasyLink:_SERVICE[nInc]) .And. ;
            Upper(oXML:_EasyLink:_SERVICE[nInc]:_ID:Text) == Upper(::cService)
            nFound++
            oXML := oXML:_EasyLink:_SERVICE[nInc]
         EndIf
      Next
   ElseIf cTipo == "O"
      If ValType(cID := ::SearchNod("ID", "Text", oXML:_EasyLink:_SERVICE)) == "C" .And. Upper(cID) == Upper(::cService)
         oXML := oXML:_EasyLink:_SERVICE
         nFound++
      EndIf
   EndIf
   
   Do Case
      Case nFound == 0
         ::cError += STR0007 + "(" + ::cService + ")"//"O servi�o n�o foi encontrado"
         lRet := .F.

      Case nFound == 1
         
         //Verifica se existem refer�ncias a arquivos XML externos.
         If !::lExtOpened .And. ::SearchNod("XMLEX",, oXML) .And. !Empty(oXML:_XMLEX:TEXT)
            //Reabre o arquivo XML j� contendo o XML externo em seu conte�do e recome�a a leitura do servi�o
            //Utiliza macro porque a estrutura do arquivo ainda n�o foi verificada, portanto o m�todo 'RetContent' n�o ir� traduzir o conte�do
            oXML := ::OpenExtRef(&(oXML:_XMLEX:TEXT))
            If Empty(::cError)
               ::lExtOpened := .T.
               Return ::ReadService(oXML)
            Else
               lRet := .F.
               Break
            EndIf
         EndIf
         
         //Verifica se as refer�ncias a campos devem ser atualizadas na base de dados
         If ValType(oInsert := ::SearchNod("INSERT_FIELDS", "SELF", oXML, .F.)) == "O" .And. ValType(oInsert := ::SearchNod(":ACTIVATED", "SELF", oInsert, .F.)) == "O" .And. oInsert:Text $ cSim
            ::lInsertFields := .T.
         EndIf
         
         //Verifica se possui a estrutura obrigat�ria DATA_SEND
         If !(::SearchNod("DATA_SEND",, oXML, .F.))
            ::cError += STR0008//"Erro na estrutura do XML. A Tag <DATA_SEND> n�o foi encontrada ou est� posicionada em local inv�lido."
         EndIf

         ::ChkStructure(oXml:_DATA_SEND)
        
         //Verifica as estruturas complementares
         If ::SearchNod("DATA_SELECTION",, oXML)
            ::ChkStructure(oXml:_DATA_SELECTION)
         EndIf
         If ::SearchNod("DATA_RECEIVE",, oXML)
            ::ChkStructure(oXml:_DATA_RECEIVE)
         EndIf
         //Caso tenha encontrado erros nas verifica��es acima, os mesmos estar�o armazenados na propriedade cError
         If !Empty(::cError)
            lRet := .F.
            Break
         EndIf

         ::oService := oXml
     
      OtherWise
         ::cError += STR0009//"Erro na estrutura do XML. Foi encontrada mais de uma ocorr�ncia ao mesmo servi�o"
   EndCase
   ::lOkStruct := lRet

End Sequence

Return lRet

/*
M�todo      : ReadXml
Classe      : EasyLink
Objetivos   : Auxiliar ao m�todo ReadService, faz a convers�o do arquivo XML em um objeto
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method __ReadXML() Class EasyLink
Local oFile
Local cXML

//RMD - 16/01/15 - Possibilita a grava��o do XML em um arquivo APH
If At(".APH", Upper(::cFile)) > 0
   cXML := &("H_" + AllTrim(StrTran(Upper(::cFile), ".APH", "")) + "()")
   oFile := XmlParser(cXML , "_" , ::cError , ::cWarning )
ElseIf File(::cFile)
   oFile := XmlParserFile(::cFile , "_" , ::cError , ::cWarning )
Else
   ::cError += STR0010 + "(" + AllTrim(::cFile) + ")"//"O arquivo .xml do servi�o n�o foi encontrado."
EndIf

Return oFile

/*
M�todo      : OpenExtRef(cFile)
Classe      : EasyLink
Par�metros  : cFile - Caminho do arquivo externo
Retorno     : oFile - Objeto XML referente ao arquivo de layout unido ao arquivo externo
Objetivos   : Abrir arquivos XML externos ao arquivo XML de layout
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 30/07/07
Revisao     :
Obs.        :
*/
Method OpenExtRef(cFile) Class EasyLink
Local cError := "", cWarning := ""
Local cXML
Local oFile

If File(cFile)
   
   //Junta o XML externo ao XML de layout do servi�o e cria um novo objeto com o conte�do da fun��o
   cXML := ::__XMLJoin(cFile)
   oFile := XmlParser(cXML , "_" , @cError , @cWarning )
   
   If !Empty(cError)
      ::cError += "Erro na abertura do arquivo de refer�ncia ###" + ENTER
      ::cError += "Descri��o: " + ENTER
      ::cError += cError + ENTER
   EndIf
   If !Empty(cWarning)
      ::cWarning += "Foram encontradas as seguintes mensagens na abertura do arquivo de refer�ncia (###)." + ENTER
      ::cWarning += "Descri��o: " + ENTER
      ::cWarning += cWarning + ENTER
   EndIf
Else
   ::cError += "Erro: O servi�o faz refer�ncia a um arquivo inexistente (###)" + ENTER
EndIf

Return oFile

/*
M�todo      : __XMLJoin(cFileFrom, cFileTo)
Classe      : EasyLink
Par�metros  : cFileFrom - Caminho do arquivo XML externo
              cFileTo   - OPCIONAL - Caminho do arquivo de layout onde o XML ser� inserido. Por padr�o, utiliza o XML do servi�o
Retorno     : Arquivo XML resultante da jun��o
Objetivos   : Inserir o conte�do de um arquivo XML dentro de outro
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 30/07/07
Revisao     :
Obs.        :
*/
Method __XMLJoin(cFileFrom, cFileTo) Class EasyLink
Local cTagJoinStart := "<XMLEX>"
Local cTagJoinEnd := "</XMLEX>"
Local nPosIni, nPosFim
Default cFileFrom := ""
Default cFileTo := ::cFile

   cFileTo := MemoRead(cFileTo)
   cFileFrom  := MemoRead(cFileFrom)
   If (nPosIni := At("<?", cFileFrom)) > 0
      nPosFim := At("?>", cFileFrom)
      cFileFrom := Left(cFileFrom, nPosIni - 1) + SubStr(cFileFrom, nPosFim + 2)
   EndIf
   If (nPosIni := At(cTagJoinStart, cFileTo)) > 0
      nPosIni  += Len(cTagJoinStart) - 1
      nPosFim  := At(cTagJoinEnd, cFileTo)
      cFileTo  := SubStr(cFileTo, 1, nPosIni) + cFileFrom + SubStr(cFileTo, nPosFim)
   EndIf
Return cFileTo

/*
M�todo      : ChkStructure(oTag, lSetNodPai)
Classe      : EasyLink
Par�metros  : oTag, lSetNodPai
Retorno     : Nenhum
Objetivos   : Adapta a estrutura do XML � estrutura entendida pelo tradutor
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method ChkStructure(oTag, lSetNodPai, lDicTagsOff) Class EasyLink
Local nInc, nChild, xChild
Default lSetNodPai := .T.
Default lDicTagsOff := .F.

Begin Sequence
   
   If oTag:TYPE == "NOD" .And. lSetNodPai
      ::SetAtributes(oTag, lDicTagsOff)
   EndIf
   If oTag:Realname == "XML"
      If Self:SearchNod("ELINKINFO",, oTag, .F.,,,, "ATT") .And. oTag:_ELINKINFO:Text == "'DICTAGS_OFF'"
         lDicTagsOff := .T.
      EndIf
   EndIf
   nChild := XmlChildCount(oTag)
   //Checa os atributos buscando em alargamento
   For nInc := 1 To nChild
      xChild := XmlGetChild(oTag, nInc)
      If ValType(xChild) == "O"
         ::SetAtributes(xChild, lDicTagsOff)
      Else
         aEval(xChild, {|x| ::SetAtributes(x, lDicTagsOff) })
      EndIf
   Next
   For nInc := 1 To nChild
      xChild := XmlGetChild(oTag, nInc)
      If ValType(xChild) == "O"
         ::ChkStructure(xChild, .F., lDicTagsOff)
      Else
         aEval(xChild, {|x| ::ChkStructure(x, .F., lDicTagsOff) })
      EndIf
   Next

End Sequence

Return Nil

/*
M�todo      : SetAtributes(oTag)
Classe      : EasyLink
Par�metros  : oTag
Objetivos   : Informa os atributos de cada tag com base no dicion�rio de tags
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method SetAtributes(oTag, lDicTagsOff) Class EasyLink
Local aDicProps
Local nInc1, nInc2, nInd
Local xNod, oProp, oTagPai := XmlGetParent(oTag)
Default lDicTagsOff := .F.

Begin Sequence
   
   If oTag:Type == "ATT"
      Break
   EndIf

   If (nPos := aScan(::aCmds, {|x| x $ Upper(oTag:RealName) })) > 0
      If (Len(oTag:RealName) == Len(::aCmds[nPos])) .Or. (Left(oTag:RealName, Len(::aCmds[nPos]) + 1) == ::aCmds[nPos] + "_")
         oTag:Type := "CMD"
         Break
      EndIf
   EndIf
      
   aDicProps := ::GetDicProps(oTag, lDicTagsOff)
   If ValType(aDicProps) <> "A"
      Break
   EndIf   
   
   For nInc1 := 1 To Len(::aAtts)
      If ::aAtts[nInc1] == "AS"
         Loop
      EndIf
      xNod := XmlChildEx(oTag, "_" + ::aAtts[nInc1])
      oProp := Nil
      If ValType(xNod) == "O" .And. xNod:Type == "ATT"
         oProp := xNod
      ElseIf ValType(xNod) == "A"
         For nInc2 := 1 To Len(xNod)
            If xNod:Type == "ATT"
               oProp := xNod[nInc2]
            EndIf
         Next
      EndIf
      If ValType(oProp) == "O"
         If ValType(oTagPai) == "O" .And. oTagPai:TYPE == "CMD"
            ::cError += StrTran(STR0012, "###", AllTrim(oProp:RealName))//"O atributo ### n�o pode ser utilizado em tags de comando."
            Break
         EndIf
      Else
         XmlNewNode ( oTag, "_" + ::aAtts[nInc1], ::aAtts[nInc1], "ATT")
         oProp := XmlChildEx(oTag, "_" + ::aAtts[nInc1])
         oProp:RealName := ::aAtts[nInc1]
      EndIf
      If ValType(oProp) == "O"
         If (nInd := aScan(aDicProps, {|x| x[1] == ::aAtts[nInc1] })) > 0
            If ValType(oProp:Text) <> "C" .Or. Empty(oProp:Text)
               oProp:Text := aDicProps[nInd][2]
            EndIf
         EndIf
         oProp:Text := "'" + oProp:Text + "'"
      EndIf
   Next
   If aScan(aDicProps, {|x| x[1] == "ISFIELD"}) > 0
      XmlNewNode (oTag, "_ISFIELD", "_ISFIELD", "ATT")
      oTag:_ISFIELD:RealName := "ISFIELD"
      oTag:_ISFIELD:Text := "'S'"
   EndIf
   
End Sequence

Return Nil

/*
M�todo      : GetDicProps(oTag)
Classe      : EasyLink
Par�metros  : oTag
Retorno     : aDicPros - Array com os atributos da tag
Objetivos   : Define os atributos de uma tag com base no dicion�rio de tags
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method GetDicProps(oTag, lDicTagsOff) Class EasyLink
Local cNome
Local aDicProps
Local xNod
Default lDicTagsOff := .F.

   If ValType(xNod := XmlChildEx(oTag, "_AS")) == Nil
      xNod := oTag
      cNome := xNod:Text
      xNod:Text := "'" + xNod:Text + "'"
   ElseIf ValType(xNod) == "A"
         xNod := xNod[1]
         cNome := xNod:Text
         xNod:Text := "'" + xNod:Text + "'"
   ElseIf ValType(xNod) <> "O"
      xNod := oTag
      cNome := xNod:RealName
   EndIf
   If cNome $ "DATA_SELECTION"
      cNome := "DATA_SELECTION"
   EndIf
   aDicProps := AvDefTag(Upper(cNome),,, lDicTagsOff)

   If ValType(aDicProps) <> "A"
      ::cError += STR0001 + Space(1) + StrTran(STR0003, "###", xNod:RealName) + ENTER//"#Erro:" ### "A Tag ### n�o est� cadastrada no dicion�rio de tags."
      Break
   EndIf

Return aDicProps

/*
M�todo      : Translate(oXML)
Classe      : EasyLink
Par�metros  : oXML
Retorno     : lRet
Objetivos   : Traduz o XML, convertendo as express�es ADVLP da se��o "DATA_SELECTION" do arquivo XML em dados
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method Translate(oXML, lEstr) Class EasyLink
Local lRet := .F.
Local nInc, nChild, oTmpXml //LRS - 01/04/2015
Default oXML := If(::lOkStruct, ::oService:_DATA_SELECTION,)
Default lEstr := .F.

Begin Sequence
   
   If (ValType(oXML) <> "O" .And. ValType(oXML) <> "A") .Or. !Empty(::cError)
      Break
   EndIf
   
   If ValType(oXML) == "A"
      For nInc := 1 To Len(oXML)
         If !(lRet := ::Translate(oXML[nInc]))
            Exit
         EndIf
      Next
      Break
   ElseIf ValType(oXML) <> "O"
      oXML := Self:oService:_Service:_Data_Selection
   EndIf
   If oXML:TYPE == "NOD"
      If (lRet := ::TranslNod(oXML))
         nChild := XmlChildCount(oXML)
         For nInc := 1 To nChild
           oTmpXml:= XmlGetChild(oXML, nInc) //LRS- 01/04/2015
           //If !(lRet := ::Translate(XmlGetChild(oXML, nInc)))
           If !(lRet := ::Translate(oTmpXml))
              Break
           EndIf
         Next
      EndIf
   ElseIf oXML:Type == "CMD"
      lRet := ::TranslCmd(oXML, lEstr)
   ElseIf oXML:Type == "ATT"
      //Verifica � um atributo interno do tradutor (neste caso n�o � necess�ria tradu��o)
      If oXML:RealName $ "TYPE/SIZE/DECIMAL/PICTURE"
         lRet := .T.
         Break
      EndIf
      //Se for um atributo do XML, traduz da mesma forma que uma tag comum
      lRet := ::TranslNod(oXML)
   EndIf

End Sequence

Return lRet

/*
M�todo      : TranslCmd(oXML)
Classe      : EasyLink
Par�metros  : oXML
Retorno     : Nenhum
Objetivos   : Traduz uma tag de comando
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method TranslCmd(oNod, lEstr) Class EasyLink
Local cCmd
Local cAlias := Alias()
Local nI, nJ, nChild, oChild, nSkip
Local cVar, nStep := 1, nIni, nTo, nInd := 0, lRepl := .F., oInst, cNewNod
Local lRet := .T.
Local lWhile := .F.
Default lEstr := .F.

Begin Sequence
   If !Empty(::cError)
      lRet := .F.
      Break
   EndIf

   Do Case
      Case "ALIAS" $ oNod:RealName
         cAlias := ::TranslNod(oNod, .T.)
         If SX2->(DbSeek(cAlias))
            DbSelectArea(cAlias)
         Else
            ::cError += STR0014//"Uso de Alias n�o existente em tags de comando."
            lRet := .F.
            Break
         EndIf
         
      Case "SEEK" $ oNod:RealName
         DbSeek(::TranslNod(oNod, .T.))

      Case "ORDER" $ oNod:RealName
         If !Empty(cAlias)
            DbSetOrder(::TranslNod(oNod, .T.))
         Else
            ::cError += STR0013//"Alias n�o definido no uso de tags de comando."
            lRet := .F.
            Break
         EndIf

      Case "IF" $ oNod:RealName
         If !::SearchNod(":COND",, oNod, .F.)
            ::cError += "Erro: A tag IF posicionada abaixo da tag ### possui condi��o inv�lida ou inexistente."
            lRet := .F.
            Break
         EndIf
         cCmd := oNod:_COND:Realname + "/" + oNod:_COND:Text
         If ::TranslNod(oNod:_COND, .T.)
            nChild := XmlChildCount(oNod)
            For nI := 1 To nChild
               oChild := XmlGetChild(oNod, nI)
               If ValType(oChild) == "O"
                  If oChild:Type <> "ATT" .And. !(lRet := ::Translate(oChild))
                     If lEstr
                        lRet := .T.
                     EndIf
                     Break
                  EndIf
               ElseIf ValType(oChild) == "A"
                  For nJ := 1 To Len(oChild)
                     If oChild[nJ]:Type <> "ATT" .And. !(lRet := ::Translate(oChild[nJ]))
                        If lEstr
                           lRet := .T.
                        EndIf
                        Break
                     EndIf
                  Next
               EndIf
            Next
            oNod:_COND:Text := ".T."
         Else
            oNod:_COND:Text := ".F."
         EndIf
      
      Case "WHILE" $ oNod:RealName
         If !::SearchNod(":COND",, oNod, .F.)
            ::cError += "Erro: A tag WHILE posicionada abaixo da tag ### possui condi��o inv�lida ou inexistente."
            lRet := .F.
            Break
         EndIf
         If ::SearchNod(":REPL",, oNod, .F.) .And. ::TranslNod(oNod:_REPL, .T.) == "1"
            lRepl := .T.
         EndIf
         ++::nWhile
         While ::TranslNod(oNod:_COND, .T.)
            lWhile := .T.
            If !::TranslEstr(oNod, lRepl, ++nInd)
               If ::lExit
                  ::lExit := .F.
                  Exit
               EndIf
               lRet := .F.
               Break
            EndIf
         EndDo
         --::nWhile
         If lRepl .Or. !lWhile
            ::TranslEstr(oNod,,, .T.)
         EndIf

      Case "SKIP" $ oNod:RealName
         cAlias := ::TranslNod(oNod, .T.)
         If ValType(cAlias) <> "C" .Or. Empty(cAlias)
            cAlias := Alias()
         EndIf
         If ::SearchNod(":RECORDS",, oNod, .F.)
            nSkip := Val(oNod:_RECORDS:Text)
         EndIf
         (cAlias)->(DbSkip(nSkip))
      
      Case "EXIT" $ oNod:RealName
         If ::nWhile == 0 .And. ::nFor == 0
            ::cError := "Erro: A tag EXIT posicionada abaixo da tag ### n�o est� relacionada a uma estrutura do tipo 'While' ou 'For'."
         Else
            ::lExit := .T.
         EndIf
         lRet := .F.
         

      Case "FOR" $ oNod:RealName
         If !::SearchNod(":INI",, oNod, .F.) .Or. !::SearchNod(":TO",, oNod, .F.)
            ::cError += "Erro: A tag FOR posicionada abaixo da tag ### n�o possui os atributos obrigat�rios 'INI' ou 'TO'."
            lRet := .F.
            Break
         Else
            nIni := ::TranslNod(oNod:_INI, .T.)
            nTo  := ::TranslNod(oNod:_TO, .T.)
         EndIf
         If ::SearchNod(":VAR",, oNod, .F.)
            cVar := ::TranslNod(oNod:_VAR, .T.)
            If aScan(::aForVars, cVar) > 0
               ::cError += "Erro: A tag FOR posicionada abaixo da tag ### utiliza vari�vel de contador que j� est� em uso em estrutura 'For' superior."
               lRet := .F.
               Break
            EndIf
            &(cVar) := 0
         Else
            cVar := "nPFor" + AllTrim(Str(Len(::aForVars)))
            &(cVar) := 0
         EndIf
         aAdd(::aForVars, cVar)
         If ::SearchNod(":STEP",, oNod, .F.)
            nStep := ::TranslNod(oNod:_STEP, .T.)
         EndIf
         If ::SearchNod(":REPL",, oNod, .F.) .And. ::TranslNod(oNod:_REPL, .T.) == "1"
            lRepl := .T.
         EndIf
         ++::nFor
         For nInd := nIni To nTo Step nStep
            &(cVar) := nInd
            If !::TranslEstr(oNod, lRepl, nInd)
               If ::lExit
                  ::lExit := .F.
                  Exit
               EndIf
               If ::lLoop
                  ::lLoop := .F.
                  Loop
               EndIf
               lRet := .F.
               Break
            EndIf
         Next
         --::nFor
         If lRepl .Or. nInd == nIni
            ::TranslEstr(oNod,,, .T.)
         EndIf
         If (nInd := aScan(::aForVars, cVar)) > 0
            aDel(::aForVars, nInd)
            aSize(::aForVars, Len(::aForVars) - 1)
         EndIf
      
      Case "LOOP" $ oNod:RealName
         If !(::nFor > 0)
            ::cError := "Erro: A tag LOOP posicionada abaixo da tag ### n�o est� relacionada a uma estrutura do tipo 'For'"
         Else
            ::lLoop := .T.
         EndIf
         lRet := .F.
      
   End Case

End Sequence

Return lRet

Method TranslEstr(oNod, lRepl, nInd, lSetOk) Class EasyLink
Local cNewNod
Local oInst, oChild
Local nChild
Local nInc, nInc2
Local lRet := .T.
Default lRepl := .F.

Begin Sequence

   If lRepl
      cNewNod := "INST_" + AllTrim(Str(nInd))
      XMLNewNode(oNod, "_" + cNewNod, cNewNod, "INS")
      oInst := ::SearchNod("_" + cNewNod, "SELF", oNod, .F.,,,, "INS")
      oInst:RealName := cNewNod
      ::BackupNod(oNod, oInst, .F., .F., {"INS", "ATT"}, .F.)
   Else
      oInst := oNod
   EndIf

   nChild := XmlChildCount(oInst)
   For nInc := 1 To nChild
      oChild := XmlGetChild(oInst, nInc)
      If ValType(oNod) == "O"
         oChild := {oChild}
      ElseIf ValType(oChild) <> "A"
         Loop
      EndIf

      For nInc2 := 1 To Len(oChild)
         If oChild[nInc2]:Type == "ATT"
            Loop
         EndIf
         If lSetOk
            If oChild[nInc2]:Type <> "INS"
               oChild[nInc2]:Type := "RPL"
            EndIf
         Else 
            If !::Translate(oChild[nInc2], .F.)
               lRet := .F.
               Exit
            EndIf
         EndIf
      Next
      If !lRet
         If ::lLoop .Or. ::lExit
            ::lLoop := .F.
         EndIf
         Exit
      EndIf
   Next

End Sequence

Return lRet

Method TagReplace(oNod, cAlias) Class EasyLink
Local nChild, nInc
Local oChild

Begin Sequence

   If cAlias <> "M"
      DbSelectArea(cAlias)
      If Select(cAlias) == 0
         ::cError += "Erro: A tag ### faz refer�ncia a uma tabela inv�lida na chamada do m�todo TagReplace"
         Break
      EndIf
   EndIf
   nChild := XmlChildCount(oNod)
   For nInc := 1 To nChild
      oChild := XmlGetChild(oNod, nInc)
      If oChild:Type <> "NOD"
         Loop
      EndIf
      If cAlias == "M"
         Eval(MemVarBlock(oChild:RealName), ::RetContent(oChild))
      Else
         Eval(FieldWBlock(oChild:RealName, Select(cAlias)), ::RetContent(oChild))
      EndIf
   Next

End Sequence

Return Nil

/*
M�todo      : TranslNod(oNod)
Classe      : EasyLink
Par�metros  : oNod
Retorno     : lRet
              lRetCont - Informa se o m�todo deve retornar o conte�do traduzido
Objetivos   : Traduz uma tag xml de express�o Advpl
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method TranslNod(oNod, lRetCont) Class EasyLink
Local lRet, xCont, oTagPai := XmlGetParent(oNod)
Local cNodName := oNod:RealName, cField, cText := oNod:Text
Default lRetCont := .F.
Private aIntData := {}


If Type("oStartTag") <> "O"
   Private oStartTag
EndIf

Begin Sequence
   
   If !Empty(::cError)
      Break
   EndIf
   
   If oNod:RealName == "DATA_RECEIVE"
      oStartTag := ::oService:_DATA_SEND
   EndIf
   
   //Procura por recorr�ncias a conte�do interno na tradu��o e aloca em �rea de dados tempor�ria   
   If !(::SetEspData(oNod, oStartTag))
      Break
   EndIf
   
   //Corrige o conte�do quando a tag possui caracteres inv�lidos
   If (Asc(oNod:Text) > 1 .And. Asc(oNod:Text) < 31) .Or. (::NodInf(oNod, "TYPE") == "C" .And. Empty(oNod:Text))
      oNod:Text := ""
      Break
   EndIf

   //Se a tag for do tipo XML e n�o tiver conte�do advpl, n�o traduz. (se executasse a tradu��o, retornaria Nil)
   If (::NodInf(oNod, "TYPE") == "X" .And. Empty(oNod:Text))
      Break
   EndIf
   
   //Traduz o conte�do//LRS - 01/04/2015 - Nopado a Valida��o onde apresentava erro log, feito outra onde n�o apresenta mais erro log
   xCont := Eval({|oEasyLink| oNod:Text}, Self)
   xCont:= &xCont

   If "CMD" $ oNod:RealName
      Break
   EndIf

   /*
   Valida o resultado da tradu��o conforme o tipo de tag.
   S�o feitas as seguintes valida��es:
      Tags de atributo (ATT): O conte�do deve ser sempre caractere, exceto quando o atributo pertence a uma tag de comando,
                              al�m disso o conte�do nunca � validado com base no dicion�rio de tags.
      Tags de comando  (CMD): N�o sofrem nenhum tipo de valida��o.
      Tags normais     (NOD): S�o validadas conforme o dicion�rio de tags.
   */
   Do Case
      Case oNod:Type == "ATT" .And. oTagPai:Type <> "CMD"
         If ValType(xCont) <> "C"
            ::cError += StrTran("A express�o do atributo ### retorna um tipo de dado diferente de caractere.", "###", AllTrim(oNod:RealName))
            Break
         EndIf

      Case oNod:Type == "NOD"
         If !(ValType(xCont) $ ::NodInf(oNod, "TYPE"))
            ::cError += StrTran(STR0016, "###", AllTrim(oNod:RealName)) + ENTER +;//"A express�o da tag ### retorna um tipo de dado diferente do definido."
                        "A express�o retornou um dado do tipo '" + ValType(xCont) + "' e era esperado o tipo '" + ::NodInf(oNod, "TYPE") + "'"
            Break
         EndIf

   End Case
   
   If lRetCont
      Break
   EndIf
   
   If oNod:Type == "NOD" .Or. (oNod:Type == "ATT" .And. oTagPai:Type <> "CMD")
      //Insere o conte�do no campo correspondente
      If ::lInsertFields .And. ValType(cField := ::SearchNod(":ISFIELD", "TEXT", oNod, .F.)) == "C" .And. cField $ cSim
         &(oNod:RealName) := xCont
      EndIf
      //Adapta o conte�do traduzido para ser armazenado na TAG
      Do Case
         Case ValType(xCont) == "C" .And. oNod:Type == "ATT"
            //Nos atributos o conte�do � sempre armazenado entre aspas
            xCont := "'" + xCont + "'"
         Case ValType(xCont) == "N"
            xCont := Str(xCont)
         Case ValType(xCont) == "L"
            If(xCont, xCont := ".T.", xCont := ".F.")
         Case ValType(xCont) == "D"
            xCont := DToC(xCont)
         Case ValType(xCont) == "O"
            //Em caso de objetos, ele � armazenado em uma �rea tempor�ria e � inserida no conte�do da tag uma refer�ncia ao mesmo
            xCont := ::AlocTempMem(xCont)
         Case ValType(xCont) == "X"
            //Em caso de tags do tipo XML o conte�do � avalidado somente no momento em que for requisitado
            xCont := ""
         Case ValType(xCont) == "A"
            xCont := ::AlocTempMem(xCont)
      End Case
      //Armazena o conte�do traduzido e adaptado
      oNod:Text := xCont
   Else
      oNod:Text := cText
   EndIf
   
End Sequence

lRet := Empty(::cError)
Return If(lRetCont, xCont, lRet)

/*
M�todo      : AlocTempMem(xData)
Classe      : EasyLink
Par�metros  : xData - Conte�do que ser� alocado em mem�ria tempor�ria
Retorno     : cRef - Refer�ncia ao conte�do na �rea de dados tempor�ria
Objetivos   : Aloca um dado em uma �rea de dados tempor�ria e retorna uma refer�ncia ao mesmo
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method AlocTempMem(xData) Class EasyLink
Local cRef

   aAdd(Self:aTempMem, xData)
   cRef := "oEasyLink:aTempMem[" + AllTrim(Str(Len(Self:aTempMem))) + "]"

Return cRef

/*
M�todo      : SetEspData(oNod, oStartTag)
Classe      : EasyLink
Par�metros  : oNod - Tag que ser� analisada
              oStartTag - Tag de in�cio de busca por conte�do interno
Retorno     : lRet
Objetivos   : Verifica se o conte�do de uma tag possui refer�ncias a conte�dos especiais, como tags externas ou internas
              e faz os tratamentos especiais para busca deste conte�do
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 25/07/2007
Revisao     :
Obs.        :
*/
Method SetEspData(oNod, oStartTag) Class EasyLink
Local lRet := .T.
Local cText := oNod:Text
Local nPosI, nPosF, nPosN, nInc
Local cNodSearch, cAttSearch, nPosOcor
Local aCmds := {{"#TAG ", "INT"}, {"#TAGEX ", "EXT"}, {"#FINDTAG", "FND"}, {"#FINDEXTAG", "FNDEX"}} 
Local aTagClass := {"N1:MESSAGE"}                                                                  //NCF - 27/11/2012 - Tag de Classe devem ser definidas para que n�o sejam
                                                                                                   //                   confundidas como atributos.
Begin Sequence
  
   For nInc := 1 To Len(aCmds)
      While (nPosI := At(aCmds[nInc][1], Upper(cText))) > 0
         nPosN := nPosI + Len(aCmds[nInc][1])
         If (nPosF := At("#", SubStr(cText, nPosN))) == 0
            ::cError += StrTran("Erro no uso de refer�ncias no conte�do da tag '###'. O operador '#' n�o foi fechado corretamente.", "###", oNod:RealName) + ENTER
            lRet := .F.
            Break
         EndIf
         
         //Define a tag que ser� buscada
         cNodSearch := AllTrim(SubStr(Upper(cText), nPosN, nPosF-1))
         If aScan(aCmds, {|x| x[1] $ cNodSearch}) > 0
            lRet := .F.
            Break
         EndIf

         //NCF - 27/11/2012 - Quando a tag � de classe, deve se substituir o caracter ":" por "_"                 
         If ( nPosOcor:=aScan(aTagClass,{|x| Upper(x) $ Upper(cNodSearch)}) ) > 0
           cNodSearch := StrTran( cNodSearch , aTagClass[nPosOcor] , StrTran(aTagClass[nPosOcor],":","_") )
         EndIf 
                 
         //Verifica se est� sendo feita a busca por um atributo de uma tag
         If (nPosAtt := At(":", cNodSearch)) > 0
             //Separa o nome da tag do nome do atributo
             //O atributo � armazendado da seguinte forma: ":NOME_DO_ATRIBUTO"
             cAttSearch := SubStr(cNodSearch, nPosAtt, Len(cNodSearch))
             cNodSearch := SubStr(cNodSearch, 1, nPosAtt - 1)
         EndIf
         
         If aCmds[nInc][2] == "INT"
            //Busca uma refer�ncia a algum conte�do interno
            cData := ::GetIntData(cNodSearch, cAttSearch, oStartTag, oNod:RealName)
         ElseIf aCmds[nInc][2] == "EXT"
            //Busca uma refer�ncia a algum conte�do externo
            cData := ::GetExtData(cNodSearch, cAttSearch, oNod:RealName)
         ElseIf aCmds[nInc][2] == "FND"
            //Verifica a exist�ncia de uma tag no arquivo
            cData := If(::SearchNod(cNodSearch), ".T.", ".F.")
         ElseIf aCmds[nInc][2] == "FNDEX"
            cData := If(::SearchNod(cNodSearch + If(ValType(cAttSearch) == "C", cAttSearch, ""),, ::oService:_XMLEX), ".T.", ".F.")
         EndIf
         
         If ValType(cData) == "L"
           lRet := .F.
           Break
         EndIf
         
         //Inclui a refer�ncia ao conte�do armazenado na �rea de dados tempor�ria do m�todo TranslNod
         cText := StrTran(cText, SubStr(cText, nPosI, nPosF + Len(aCmds[nInc][1])), cData)
      End Do
   Next
   If Upper(oNod:Text) <> Upper(cText)
      oNod:Text := cText
   EndIf

End Sequence

Return lRet

/*
M�todo      : GetIntData(cNodSearch, cAttSearch, oStartTag, cTag)
Classe      : EasyLink
Par�metros  : cNodSearch - Tag a ser buscada
              cAttSearch - Atributo da tag a ser buscada
              oStartTag  - Objeto XML de in�cio da busca
              cTag       - Nome da tag que requisitou o conte�do
Retorno     : xRet - Refer�ncia ao conte�do solicitado
Objetivos   : Faz a busca por um conte�do interno da tradu��o e aloca este conte�do na �rea de dados tempor�ria do m�todo TranslNod,
              retornando uma refer�ncia ao mesmo.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 27/07/2007
Revisao     :
Obs.        :
*/
Method GetIntData(cNodSearch, cAttSearch, oStartTag, cTag) Class EasyLink
Local xRet
Local cError := "", cAuxError := ""

Begin Sequence

   //Busca o conte�do solicitado
   If ValType(xRet := ::SearchNod(cNodSearch, "TEXT", oStartTag, , , , cAttSearch)) <> "L"
      //Armazena o conte�do na �rea de dados tempor�ria
      aAdd(aIntData, xRet)
      xRet := "aIntData[" + AllTrim(Str(Len(aIntData))) + "]"
   Else
      cError += StrTran("Erro no conte�do da tag '###'.", "###", cTag) + ENTER
      cError += StrTran("A Tag XXX n�o foi encontradaYYY.", "XXX", cNodSearch)
      If !Empty(cAttSearch)
         cAuxError += StrTran(" ou o atributo ### � inv�lido", "###", cAttSearch)
      EndIf
      cError := StrTran(cError, "YYY", cAuxError)
      xRet := .F.
      Break
   EndIf
   
End Sequence

::cError += cError

Return xRet

/*
M�todo      : GetExtData(cNodSearch, cAttSearch, cTag)
Classe      : EasyLink
Par�metros  : cNodSearch - Tag a ser buscada
              cAttSearch - Atributo da tag a ser buscada
              cNod - Nome da tag que requisitou o conte�do
Retorno     : xRet - Refer�ncia ao conte�do externo solicitado
Objetivos   : Faz a busca por um conte�do externo da tradu��o e aloca este conte�do na �rea de dados tempor�ria do m�todo TranslNod,
              retornando uma refer�ncia ao mesmo.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 27/07/2007
Revisao     :
Obs.        :
*/
Method GetExtData(cNodSearch, cAttSearch, cTag) Class EasyLink
Local xRet := .F., nInc
Local oXMLExt

Begin Sequence
   
   If ValType(xRet := ::SearchNod("XMLEX", , ::oService)) == "L" .And. !xRet
      ::cError += StrTran("A tag '###' faz refer�ncia a uma fonte externa n�o declarada.", "###", cTag)
      Break
   EndIf
   
   oXMLExt := ::oService:_XMLEX
   
   If ValType(xRet := ::SearchNod(cNodSearch, "Self", oXMLExt, , , , cAttSearch)) == "L" .And. !xRet
      ::cError += StrTran("A tag '###' n�o foi encontrada no arquivo externo.", "###", cNodSearch + If(ValType(cAttSearch) == "C", cAttSearch, ""))
      Break
   EndIf
   
   If ValType(xRet) == "A"
      For nInc := 1 To Len(xRet)
         //If Empty(cAttSearch)
            If ValType(xRet[nInc]) == "O"
               xRet[nInc] := xRet[nInc]:Text
            EndIf
         //Else
         //   If ValType(oAtt := ::SearchNod(":" + cAttSearch, "Self", xRet[nInc])) == "O"
         //      xRet[nInc] := oAtt:Text
         //   EndIf
         //EndIf
      Next
   Else
      xRet := xRet:Text
   EndIf
   
   //Armazena o conte�do na �rea de dados tempor�ria
   aAdd(aIntData, xRet)
   xRet := "aIntData[" + AllTrim(Str(Len(aIntData))) + "]"

End Sequence

Return xRet

/*
M�todo      : NodInf(oNod, cInf)
Classe      : EasyLink
Par�metros  : oNod, cInf
Retorno     : xRet - Informa��o solicitada
Objetivos   : Retorna informa��es sobre a tag, com base nas informa��es obtidas com o dicion�rio de tags
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method NodInf(oNod, cInf) Class EasyLink
Local xRet := ""
Default cInf := ""

   oInf := XmlChildEx (oNod, "_" + cInf)
   If ValType(oInf) == "O"
      xRet := SubStr(oInf:Text, 2, Len(oInf:Text)-2)
      If oInf:RealName $ "SIZE/DECIMAL"
         xRet := Val(xRet)
      EndIf
   EndIf

Return xRet

/*
M�todo      : SearchNod(cNod, cRet, oNod, lSearchAll, _nNivel, _nNivelMax)
Classe      : EasyLink
Par�metros  : cNod - tag a ser procurada
              cRet - Opcional - Informa��o a ser retornada, podendo ser: RealName, Text, Self, ou nenhum (neste caso retorna valor l�gico)
              oNod - Opcional - Objeto que servir� como ponto de partida para a busca
              lSearchAll - Informa se a busca ser� feita tamb�m nos n�veis inferiores (tags contidas na tag inicial)
              _nNivel - Interno - N�vel atual da busca
              _nNivelMax - Interno - N�vel m�ximo que a busca ir� atingir
              cType - Indica qual tipo de objeto est� sendo buscado
              cAtt - Atributo que ser� retornado (da tag procurada)
Retorno     : xRet - Tag encontrada ou o conte�do solicitado da mesma
Objetivos   : Faz a busca de uma tag dentro do objeto xml
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method SearchNod(cNod, cRet, oNod, lSearchAll, _nNivel, _nNivelMax, cAtt, cType, __aNod) Class EasyLink
Local xRet := .F.
Local nInc, nChild := 0
Local cTipo
Local oChild
Local aRet
Local lInst := .F.
Default cType := "NOD"
Default cRet := ""
Default oNod := If(::lOkStruct, ::oService:_DATA_SELECTION,)
Default lSearchAll := .T.
Default _nNivel    := 0
Default _nNivelMax := 0
Default cAtt := ""
Default __aNod := {}

Begin Sequence

   If Left(cNod, 1) == ":"//O prefixo ":" indica a busca por um atributo
      cNod := Right(cNod, Len(cNod) - 1)//Retira o prefixo do nome do atributo
      cType := "ATT"//Define que ser� feita a busca somente em atributos
   EndIf

   //Indica que um caminho de tags foi informado
   If At("\", cNod) > 0
      __aNod := ::Split(cNod)
      cNod := __aNod[Len(__aNod)]
   EndIf

   //Define o n�vel m�ximo de busca
   If !lSearchAll
      _nNivelMax := 1
   EndIf

   //Verifica se ultrapassou o n�vel m�ximo de busca
   If _nNivelMax > 0 .And. _nNivel > _nNivelMax
      Break
   EndIf

   If (cTipo := ValType(oNod)) == "O"
      //Verifica o caminho de tags que foi informado
      If Len(__aNod) > 0 .And. _nNivel > 0 .And. _nNivel <= Len(__aNod) .And. Upper(StrTran(oNod:RealName, ":", "_")) <> Upper(__aNod[_nNivel])
         Break
      EndIf
      //Verifica se est� posicionado na tag procurada
      If Upper(oNod:RealName) == Upper(cNod)  .And. oNod:TYPE == cType//A propriedade type indica se o objeto corresponde a uma tag (TAG) ou atributo (ATT)
      //If Upper(StrTran(oNod:RealName, ":", "_")) == Upper(cNod)  .And. oNod:TYPE == cType//A propriedade type indica se o objeto corresponde a uma tag (TAG) ou atributo (ATT)
         xRet := oNod//Se encontrada a tag, encerra a busca (final das recurs�es)
      EndIf
   EndIf

   If ValType(xRet) == "L" .And. !xRet .And. (_nNivelMax == 0 .Or. (cTipo <> "O" .Or. _nNivel < _nNivelMax))
      If cTipo == "O"
         //Verifica o n�mero de tags "filhas" da atual, se a mesma n�o for um atributo
         If oNod:Type <> "ATT"
            nChild := XmlChildCount(oNod)
         EndIf
         If (Left(Upper(oNod:RealName), 3) == "FOR" .Or. Left(Upper(oNod:RealName), 5) == "WHILE");
            .And. ValType(XmlChildEx(oNod, "_REPL")) == "O" .And. ::TranslNod(oNod:_REPL, .T.) == "1" .And. aScan(::aAuxAtts, cNod) == 0
            lInst := .T.
            aRet := {}
         EndIf
      ElseIf cTipo == "A"//� poss�vel encontrar um "Array" de tags, que dever� ser percorrido assim como o objeto
         nChild := Len(oNod)
         aRet := {}
      Else
         //Somente chega a esta condi��o se ocorrer um erro, neste caso encerra a busca retornando .F.
         Break
      EndIf
      
      //Obt�m o objeto das tags "filhas" da atual
      For nInc := 1 To nChild
         If cTipo == "O"
            oChild := XmlGetChild(oNod, nInc)
         Else//"A"
            oChild := oNod[nInc]
         EndIf

//         If lInst .And. oChild:Type <> "INS"
//            Loop
//         EndIf
      
         //Faz a busca em profundidade nas tags "filhas"
         xRet := ::SearchNod(cNod, cRet, oChild,, _nNivel + If(cTipo <> "O", 0, 1), _nNivelMax, cAtt, cType, __aNod)
      
         If ValType(xRet) <> "L" .Or. xRet
            If ValType(aRet) == "A"
               aAdd(aRet, xRet)
               Loop
            EndIf
            Exit
         EndIf
      Next
      If cTipo == "A" .And. (ValType(xRet) <> "L" .Or. xRet)
         xRet := aRet
      EndIf
      If lInst .And. (ValType(xRet) <> "L" .Or. xRet)
         xRet := aRet[Len(aRet)]
      EndIf
   EndIf
   
   If ValType(xRet) <> "L" .Or. xRet
      If _nNivel == 0
         If !Empty(cAtt)
            //Busca o atributo da tag em alargamento e somente no primeiro n�vel.
            If ValType(xRet) <> "A"
               xRet := ::SearchNod(cAtt, cRet, xRet,,, 1)
            Else
               aRet := {}
               For nInc := 1 To Len(xRet)
                  xRet[nInc] := ::SearchNod(cAtt, cRet, xRet[nInc],,, 1)
                  If ValType(xRet[nInc]) <> "L" .Or. xRet[nInc]                    //NCF - 15/08/2012 - Verifica��o da vari�vel xRet como array e n�o como l�gica
                     aAdd(aRet, xRet[nInc])
                  EndIf
               Next
               xRet := aRet
            EndIf
         Else
            cRet := Upper(cRet)
            Do Case
               Case cRet == "REALNAME" .Or. cRet == "NAME"
                  xRet := xRet:RealName
               Case cRet == "TYPE"
                  xRet := xRet:Type
               Case cRet == "TEXT"
                  xRet := ::RetContent(xRet)
               Case cRet == "SELF"
                  xRet := xRet
               Otherwise
                  xRet := .T.
            EndCase
         EndIf
      EndIf
   EndIf

End Sequence

Return xRet

Method Split(cNodes) Class EasyLink
Local aNodes := {}
Local nPos

   While (nPos := At("\", cNodes)) > 0
      aAdd(aNodes, Left(cNodes, nPos-1))
      cNodes := Right(cNodes, Len(cNodes) - nPos)
   EndDo
   aAdd(aNodes, cNodes)

Return aNodes

/*
M�todo      : RetContent(oTag)
Classe      : EasyLink
Par�metros  : oTag
Retorno     : xContent - Conte�do da tag
Objetivos   : Retorna o conte�do de uma tag
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method RetContent(oTag) Class EasyLink
Local nInc1, nInc2
Local xContent, xChild
Local lArrayTag := .F.
Local aAtts
Private oEasyLink := Self

Begin Sequence
   If ValType(oTag) == "A"
      oTag := oTag[Len(oTag)]
   EndIf
   If !::lOkStruct .Or. !(::ChkInfo(oTag))
      xContent := oTag:Text
      If oTag:Type == "ATT" .And. Left(xContent, 1) == "'" .And. Right(xContent, 1) == "'"
         xContent := SubStr(xContent, 2, Len(xContent) - 2)
      EndIf
   Else
      Do Case
         Case "C" $ Upper(oTag:_Type:Text)
            xContent := oTag:Text
            
         Case "N" $ Upper(oTag:_Type:Text)
            xContent := Val(oTag:Text)
             
         Case "D" $ Upper(oTag:_Type:Text)
            xContent := CToD(oTag:Text)
            
         Case "O" $ Upper(oTag:_Type:Text)
            xContent := &(oTag:Text)
         
         Case "X" $ Upper(oTag:_Type:Text)
            xContent := ::BackupNod(oTag,, .T.)
            xContent := XMLSaveStr(xContent)

         Case "T" $ Upper(oTag:_Type:Text)
            xContent := oTag
            
         Case "A" $ Upper(oTag:_Type:Text)
            xContent := {}
            
            If Self:cInt <> "002"//Se a integra��o n�o for com o Inttra.
               aAtts := aClone(::aAtts)
               ::aAtts := {}
               oTag := ::BackupNod(oTag,, .T.)
               ::aAtts := aClone(aAtts)
               For nInc1 := 1 To XmlChildCount(oTag)
                  xChild := XmlGetChild(oTag, nInc1)
                  If ValType(xChild) == "A"
                     For nInc2 := 1 To Len(xChild)
                        aAdd(xContent, ::RetContent(xChild[nInc2]))
                     Next
                  ElseIf ValType(xChild) == "O" .And. xChild:Type == "NOD"
                     aAdd(xContent, ::RetContent(xChild))
                  EndIf
               Next
            Else
               /* RMD - 08/2009
                  Quando a integra��o for com o Inttra (c�d. 002), o tratamento para retorno de arrays � 
                  diferenciado, pois a id�ia � retornar um array de objetos, e n�o um array com o conte�do final de 
                  cada tag, como � feito na integra��o com o financeiro.
                  Posteriormente ser� necess�rio definir como avaliar em tempo de execu��o qual � a forma correta de 
                  tratar o array, para que n�o fique amarrado a nenhuma integra��o em especial.
               */
               For nInc1 := 1 To XmlChildCount(oTag)
                  xChild := XmlGetChild(oTag, nInc1)
                  If xChild:Type == "NOD"
                      lArrayTag := .T.
                     Exit
                  EndIf
               Next
               If !lArrayTag
                  xContent := &(oTag:Text)
               EndIf
            EndIf
            
      End Case
   EndIf

End Sequence

Return xContent

/*
M�todo      : BackupNod(oNod, oBackup, lRemoveControls, lCopyRoot, aNotCopy, lValidAll, __nNivel)
Classe      : EasyLink
Par�metros  : oNod - Objeto da tag que dever� feito o backup
              oBackup - OPCIONAL - Objeto onde ser� feito o backup
              lRemoveControls - OPCIONAL - Indica se ser�o removidos todos os controle internos do XML, preparando-o para um envio externo
              lCopyRoot - OPCIONAL - Indica se o primeiro n�vel da tag "oNod" ser� copiado, caso contr�rio ser�o copiadas somente as tags filhas
              aNotCopy - OPCIONAL - Array com os tipos de tag que n�o devem ser copiados
              lValidAll - OPCIONAL - Define se as regras informadas em "aNotCopy" valem para todos os n�veis ou somente at� o primeiro
              __nNivel - INTERNO - Indica o n�vel da tag inicial que est� sendo verificado (quantidade de recurs�es)
Retorno     : oBackup - Objeto contendo o backup da tag
Objetivos   : Fazer o backup de uma tag e de todo o seu conte�do, incluindo as tags internas
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method BackupNod(oNod, oBackup, lRemoveControls, lCopyRoot, aNotCopy, lValidAll, __nNivel) Class EasyLink
Local nChild, nInc
Local cTipo, cTempName := "", cNewNod
Local oNewTag, oChild
Default aNotCopy := {}
Default lValidAll := .T.
Default lCopyRoot := .T.
Default lRemoveControls := .F.
Default __nNivel := 0

Begin Sequence 

   //Cria objeto tag para na raiz do servi�o para efetuar o backup, caso a mesma n�o tenha sido informada
   If ValType(oBackup) <> "O"
      If !(::SearchNod("BACKUP",, ::oService, .F.))
         XMLNewNode(::oService, "_BACKUP", "BACKUP", "NOD")
         ::oService:_BACKUP:RealName := "BACKUP"
      EndIf
      cTempName := UUIDRandom()//CriaTrab(,.F.)
      XMLNewNode(::oService:_BACKUP, "_" + cTempName, cTempName, "NOD")
      oBackup := ::SearchNod("_" + cTempName, "Self", ::oService:_Backup, .F.)
      oBackup:RealName := cTempName
      cTempName := ""
   EndIf

   If Len(aNotCopy) > 0 .And. !lValidAll .And. __nNivel > 1
      aNotCopy := {}
   EndIf

   //Incia o backup
   If ValType(oNod) == "O"
      //N�o copia tags dos tipos informados no array aNotCopy
      If aScan(aNotCopy, oNod:Type) <> 0
         Break
      EndIf
      //Retira todas as tags e atributos espec�ficos da tradu��o, "limpando" o xml para sa�da do sistema
      If lRemoveControls
         //N�o copia os atributos que indicam o tipo de dado (relacionados em aAtts)
         //al�m disso, n�o verifica suas tags filhas (dando o break as tags filhas n�o s�o visitadas)
         If oNod:Type == "ATT"
            If (aScan(::aAtts, Upper(oNod:RealName)) > 0 .Or. aScan(::aAuxAtts, Upper(oNod:RealName)) > 0)
               Break
            EndIf
            If (Left(AllTrim(oNod:Text), 1) == "'" .Or. Left(AllTrim(oNod:Text), 1) == '"') .And. ;
               (Right(AllTrim(oNod:Text), 1) == "'" .Or. Right(AllTrim(oNod:Text), 1) == '"')
               oNod:Text := SubStr(AllTrim(oNod:Text), 2)
               oNod:Text := Left(oNod:Text, Len(oNod:Text) - 1)
            EndIf
         EndIf
         //As tags que j� foram replicadas tamb�m n�o s�o copiadas
         If oNod:Type == "RPL"
            Break
         EndIf
         If oNod:Type == "CMD"
            If Left(Upper(oNod:RealName), 2) == "IF" .And. !(&(oNod:_COND:Text))
               Break
            EndIf
            lCopyRoot := .F.
         EndIf
         If oNod:Type == "INS"
            lCopyRoot := .F.
         EndIf
         If oNod:Type == "NOD"
            If ::SearchNod(":PRINT",, oNod, .F.) .And. &(oNod:_Print:Text) == "N"
               Break
            ElseIf Upper(oNod:RealName) = "CMD"
               Break
            EndIf
         EndIf
      EndIf
      //Se a tag atual for copiada, ela se torna a tag de destino, sen�o ela continua sendo a indicada em oBackup
      If lCopyRoot
         If ::SearchNod(oNod:RealName,, oBackup, .F.,,,, oNod:Type)
            cTempName := UUIDRandom()//CriaTrab(,.F.)
         EndIf
         cNewNod := "_" + oNod:RealName
         XmlNewNode(oBackup, cNewNod + cTempName, oNod:RealName, oNod:Type)
         oBackup := ::SearchNod(cNewNod + cTempName, "Self", oBackup, .F.,,,, oNod:Type)
         oBackup:RealName := oNod:RealName
         oBackup:Text := oNod:Text
      EndIf
   EndIf

   If (cTipo := ValType(oNod)) == "O"
      nChild := XmlChildCount(oNod)
   ElseIf cTipo == "A"
      nChild := Len(oNod)
   EndIf
   
   //Obt�m o objeto das tags "filhas" da atual e faz o tratamento para cada uma delas
   For nInc := 1 To nChild
      If cTipo == "O"
         oChild := XmlGetChild(oNod, nInc)
      ElseIf cTipo == "A"
         oChild := oNod[nInc]
      EndIf
      aNotCopyTemp := aClone(aNotCopy) //MCF - 18/11/2015 - Na P12 o aClone passado como parametro retorna NIL.
      ::BackupNod(oChild, oBackup, lRemoveControls, .T.,/*aClone(aNotCopy)*/ aNotCopyTemp, lValidAll, __nNivel + 1)
   Next

End Sequence
   
Return oBackup

/*
M�todo      : ChkInfo(oNod)
Classe      : EasyLink
Par�metros  : oNod - Objeto da tag que dever� verificada
Retorno     : lRet
Objetivos   : Verifica se o objeto da tag possui todos os atributos do dicion�rio de tags utilizados pelo tradutor
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method ChkInfo(oNod) Class EasyLink
Local lRet

   lRet := ::SearchNod(":TYPE",, oNod, .F.) .And.;
           ::SearchNod(":SIZE",, oNod, .F.) .And.;
           ::SearchNod(":DECIMAL",, oNod, .F.) .And.;
           ::SearchNod(":PICTURE",, oNod, .F.)

Return lRet

Method NewVar(cVar, xData) Class EasyLink
Local nPos

   If ValType(cVar) == "C" .And. Len(cVar) > 0
      If (nPos := aScan(::aVars, {|x| x[1] == cVar})) > 0
         ::aVars[nPos][2] := xData
      Else
         aAdd(::aVars, {cVar, xData})
      EndIf
   EndIf

Return xData

Method SetVar(cVar, xData) Class EasyLink
Local nPos

   If ValType(cVar) == "C" .And. Len(cVar) > 0
      If (nPos := aScan(::aVars, {|x| x[1] == cVar})) > 0
         ::aVars[nPos][2] := xData
      Else
         xData := Nil
      EndIf
   EndIf

Return xData

Method RetVar(cVar) Class EasyLink
Local nPos, xData

   If ValType(cVar) == "C" .And. Len(cVar) > 0
      If (nPos := aScan(::aVars, {|x| x[1] == cVar})) > 0
         xData := ::aVars[nPos][2]
      EndIf
   EndIf

Return xData

/*
M�todo      : Send()
Classe      : EasyLink
Par�metros  : Nenhum
Retorno     : lRet
Objetivos   : Envia os dados do servi�o, executando os comandos da se��o "DATA_SEND" do arquivo XML
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method Send() Class EasyLink
Local lRet
Local oData_Send
   
   If Empty(::cError) .And. ValType(oData_Send := ::SearchNod("DATA_SEND", "Self", ::oService)) == "O"
      If (lRet := ::Translate(oData_Send))
         If !(lRet := Empty(oData_Send:_Send:Text))
            ::cError := oData_Send:_Send:Text + ENTER + ::cError
         EndIf
      EndIf
   EndIf
   
Return lRet

/*
M�todo      : Receive()
Classe      : EasyLink
Par�metros  : Nenhum
Retorno     : lRet
Objetivos   : Recebe os dados do servi�o, executando os comandos da se��o "DATA_RECEIVE" do arquivo XML
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method Receive() Class EasyLink
Local lRet := .T.
Local oData_Receive, oSrv_Status, oSrv_Msg

Begin Sequence   
   If !Empty(::cError)
      lRet := .F.
      Break
   EndIf
   If ValType(oData_Receive := ::SearchNod("DATA_RECEIVE", "Self", ::oService)) == "O"
      lRet := ::Translate(oData_Receive)
      If !lRet
         ::cError := STR0017 + ENTER + ::cError//"Erro na tradu��o do conte�do da tag <DATA_RECEIVE>."
         lRet := .F.
         Break
      EndIf
      If ValType(oSrv_Status := ::SearchNod("SRV_STATUS", "Self", oData_Receive)) == "O"
         If(oSrv_Status:Text $ ".T.", lRet := .T., lRet := .F.)
      EndIf
      If ValType(oSrv_Msg := ::SearchNod("SRV_MSG", "Self", oData_Receive)) == "O"
         If lRet
            ::cError += oSrv_Msg:Text
         Else
            ::cWarning += oSrv_Msg:Text
         EndIf
      EndIf
   EndIf
End Sequence

Return lRet

/*
M�todo      : RetMsg()
Classe      : EasyLink
Par�metros  : Nenhum
Retorno     : cMsg - Mensagens consolidadas
Objetivos   : Retorna as mensagens obtidas durante a leitura e tradu��o do XML
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method RetMsg() Class EasyLink
Local cMsg := ""

cMsg += STR0018 + ": " + ENTER//"Avisos"
cMsg += Self:cWarning + ENTER
cMsg += STR0019 + ": " + ENTER//"Erros"
cMsg += Self:cError + ENTER

Return cMsg

/*
Fun��o      : AvDefTag(cNome, cProp, cPai)
Objetivos   : Retorna as informa��es de uma tag conforme o dicion�rio de tags
Par�metros  : cNome, cProp, cPai
Retorno     : xRet - Defini��es da tag
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/07
Revisao     :
Obs.        :
*/
Function AvDefTag(cNome, cProp, cPai, lDicTagsOff)
Local aOrd := SaveOrd("SX3")
Local cArea := Alias()
Local nInc, nPos
Local aRet := {{"TYPE"   ,},;
               {"SIZE"   ,},;
               {"DECIMAL",},;
               {"PICTURE",}}
Local bAddData := {|x,y| If(ValType(y)<>"C", y := Str(y),), aAdd(aRet, {x,y})}
Local bSetData := {|x,y| If(ValType(y)<>"C", y := Str(y),), aRet[x][2] := y}
Local xRet
Default lDicTagsOff := .F.

Begin Sequence

   SX3->(DbSetOrder(2))
   DbSelectArea("EYD")
   DbSetOrder(1)
   //If SX3->(DbSeek(AvKey(cNome, "X3_CAMPO"))) // nopado por DFS 05/07/2010
   If !lDicTagsOff .And. SX3->(DbSeek(AvKey(cNome, "X3_CAMPO"))) .And. !DbSeek(xFilial()+AvKey(cNome, "EYD_NAME"))
      nPos := aScan(aRet, {|x| "TYPE" $ x[1] })
      aRet[nPos][2] := AvSx3(cNome, AV_TIPO)
      nPos := aScan(aRet, {|x| "SIZE" $ x[1] })
      aRet[nPos][2] := Str(AvSx3(cNome, AV_TAMANHO))
      nPos := aScan(aRet, {|x| "DECIMAL" $ x[1] })
      aRet[nPos][2] := Str(AvSx3(cNome, AV_DECIMAL))
      nPos := aScan(aRet, {|x| "PICTURE" $ x[1] })
      aRet[nPos][2] := AvSx3(cNome, AV_PICTURE)
      xRet := aRet
      aAdd(aRet, {"ISFIELD", "S"})
   Else
      If !lDicTagsOff .And. DbSeek(xFilial()+AvKey(cNome, "EYD_NAME"))
         For nInc := 3 To FCount()
            cCampo := Right(FieldName(nInc), Len(FieldName(nInc)) - At("_", FieldName(nInc)))
            If (nPos :=  aScan(aRet, {|x| cCampo $ x[1] })) > 0
               Eval(bSetData, nPos, &(FieldName(nInc)))
            Else
               Eval(bAddData, cCampo, &(FieldName(nInc)) ) 
            EndIf
         Next
         xRet := aRet

         If !Empty(cProp) .And. (nPos := aScan(aRet, {|x| x[1] == cProp })) > 0
            xRet := aRet[nPos][2]
         EndIf
      Else
         xRet := {{"TYPE"   , "C" },;
                  {"SIZE"   , "250"},;
                  {"DECIMAL", "0" },;
                  {"PICTURE", ""  }}         
      EndIf
   EndIf
   
End Sequence

If ValType(xRet) == "A"
   aEval(xRet, {|x| x[2] := AllTrim(x[2]) })
EndIf
RestOrd(aOrd, .T.)
If !Empty(cArea)
   DbSelectArea(cArea)
EndIf

Return xRet

/*
Classe      : EasyLinkLog
Objetivos   : Classe de gerenciamento do log de contrata��es
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Class EasyLinkLog

Data cAction
Data cId
Data cIdEv
Data lOkAc
Data cAcMsg
Data lOkEv
Data cEvMsg
Data dDataI
Data cHoraI
Data dDataF
Data cHoraF
Data aErros
Data aLogID

Method New(cAction) Constructor
Method SaveLog(oEasyLink)
Method EndLog()
Method SetEvent(cInt, cEvent, cService)
Method EndEvent()
Method AcMsg(cAcMsg, lOkAc)
Method EvMsg(cEvMsg, lOkEv)
Method SetLogID(cID,cIDOrigem,cRecno)
Method GetLogID()

End Class

/*
M�todo      : New
Classe      : EasyLinkLog
Par�metros  : cAction
Retorno     : Self
Objetivos   : Cria uma nova inst�ncia da classe e um novo registro na tabela de registro de contrata��es
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method New(cAction) Class EasyLinkLog

Begin Sequence

   ::lOkAc  := .T.
   ::cAcMsg := ""
   ::lOkEv  := .T.
   ::cEvMsg := ""
   ::dDataI := Date()
   ::cHoraI := Time()
   
   ::aErros := {}
   ::aLogID := {}

   ::cAction := cAction
   ::cID := GetSxeNum("EYF", "EYF_ID")
   ConfirmSx8()

   EYF->(RecLock("EYF", .T.))
   EYF->EYF_FILIAL := xFilial("EYF")
   EYF->EYF_ID     := ::cID
   EYF->EYF_CODAC  := cAction
   EYF->EYF_DESAC  := Posicione("EYB", 1, xFilial("EYB")+cAction, "EYB_DESAC")
   EYF->EYF_DATAI  := ::dDataI
   EYF->EYF_HORAI  := ::cHoraI
   EYF->EYF_USER   := AllTrim(cUserName)
   EYF->EYF_STATUS := "01"
   EYF->EYF_DESSTA := STR0020//"A��o n�o conclu�da"
   EYF->(MsUnlock())
   
   ::SetLogID(EYF->EYF_ID, EYF->EYF_IDORI, EYF->(Recno()), EYF->({EYF_FILIAL, EYF_DESSTA, EYF_STATUS, EYF_DATAI, EYF_HORAI, EYF_DATAF, EYF_HORAF, EYF_ARQXML, EYF_USER, EYF_ID, EYF_IDORI, EYF_NOMINT, EYF_CODINT, EYF_CODAC, EYF_DESAC, EYF_CODEVE, EYF_CODSRV}))
End Sequence

Return Self

/*
M�todo      : SaveLog(oEasyLink)
Classe      : EasyLinkLog
Par�metros  : oEasyLink
Retorno     : Nenhum
Objetivos   : Grava as informa��es de log armazenadas no objeto em um arquivo f�sico
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method SaveLog(oEasyLink) Class EasyLinkLog
Local cFile := EasyGParam("MV_AVG0135",,"\XML") + "\Log\" + ::cIdEv
Local hFile, cXml := ""

// PLB 14/08/07 - Acerta Diretorio
If IsSrvUNIX()
   cFile := AllTrim(Lower(StrTran(cFile, '\', '/')))
EndIf

//wfs
CriaDirLog()

Begin Sequence

   If ValType(oEasyLink) == "O"
      If oEasyLink:lOkStruct
         SAVE oEasyLink:oService XMLSTRING cXML
   
         If !File(cFile + ".xml")
            hFile := EasyCreateFile(cFile + ".xml")
         Else
            hFile := EasyOpenFile(cFile + ".xml")
         EndIf
         FWrite(hFile, "<XML>" + cXml + "</XML>")
         FClose(hFile)
      EndIf
   
   Else

      If !Empty(::cEvMsg)
         If !File(cFile + ".txt")
            hFile := EasyCreateFile(cFile + ".txt")
         Else
            hFile := EasyOpenFile(cFile + ".txt")
            ::cEvMsg := ENTER + ::cEvMsg
         EndIf
         If EasyGParam("MV_AVG0132",,.F.)
            ::cEvMsg += ENTER 
            ::cEvMsg += "Log do Ambiente:" + ENTER
            ::cEvMsg += GetEnvLog()
         EndIf
         FWrite(hFile, ::cEvMsg)
         FClose(hFile)
         ::lOkEv  := .F.
      EndIf
   EndIf
      

End Sequence
   
Return Nil

/*
M�todo      : EndLog()
Classe      : EasyLinkLog
Par�metros  : Nenhum
Retorno     : Nenhum
Objetivos   : Grava as informa��es de log armazenadas no objeto em um arquivo f�sico
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method EndLog() Class EasyLinkLog
Local aOrd := SaveOrd("EYF")
Local nInc, cErros := ""

Begin Sequence

   If Empty(::cID)
      Break
   EndIf
   ::dDataF := Date()
   ::cHoraF := Time()

   EYF->(DbSetOrder(1))
   If EYF->(DbSeek(xFilial()+::cID))
      EYF->(RecLock("EYF", .F.))
      EYF->EYF_DATAF  := ::dDataF
      EYF->EYF_HORAF  := ::cHoraF
      If ::lOkAc
         EYF->EYF_STATUS := "02"
         EYF->EYF_DESSTA := STR0021//"A��o conclu�da"
      Else
         EYF->EYF_STATUS := "01"
         EYF->EYF_DESSTA := STR0020//"A��o n�o conclu�da"
      EndIf
   EndIf
   For nInc := 1 To Len(::aErros)
      cErros += ::aErros[nInc][2]
   Next

End Sequence

RestOrd(aOrd, .T.)   
Return cErros

/*
M�todo      : SetEvent(cInt, cEvent, cService)
Classe      : EasyLinkLog
Par�metros  : cInt, cEvent, cService
Retorno     : Nenhum
Objetivos   : Inclui uma nova contrata��o de evento na a��o gerenciada
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method SetEvent(cInt, cEvent, cService) Class EasyLinkLog

Begin Sequence
   
   RecLock("EYF", .T.)
   ::cIdEv := GetSxeNum("EYF", "EYF_ID")
   ConfirmSx8()
   EYF->EYF_FILIAL := xFilial("EYF")
   EYF->EYF_ID     := ::cIDEv
   EYF->EYF_IDORI  := ::cID
   EYF->EYF_CODAC  := ::cAction
   EYF->EYF_DESAC  := Posicione("EYB", 1, xFilial("EYB")+::cAction, "EYB_DESAC")
   EYF->EYF_CODINT := cInt
   EYF->EYF_NOMINT := Posicione("EYA", 1, xFilial("EYA")+cInt, "EYA_NOMINT")
   EYF->EYF_CODEVE := cEvent
   EYF->EYF_CODSRV := cService
   EYF->EYF_DATAI  := Date()
   EYF->EYF_HORAI  := Time()
   EYF->EYF_USER   := AllTrim(cUserName)
   EYF->EYF_STATUS := "03"
   EYF->EYF_DESSTA := STR0022//"Contrata��o n�o conclu�da"
   MsUnlock()
   
   ::SetLogID(EYF->EYF_ID, EYF->EYF_IDORI, EYF->(Recno()), EYF->({EYF_FILIAL, EYF_DESSTA, EYF_STATUS, EYF_DATAI, EYF_HORAI, EYF_DATAF, EYF_HORAF, EYF_ARQXML, EYF_USER, EYF_ID, EYF_IDORI, EYF_NOMINT, EYF_CODINT, EYF_CODAC, EYF_DESAC, EYF_CODEVE, EYF_CODSRV}))
End Sequence
   
Return Nil

/*
M�todo      : EndEvent()
Classe      : EasyLinkLog
Par�metros  : Nenhum
Retorno     : Nenhum
Objetivos   : Finaliza o gerenciamento do evento
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method EndEvent() Class EasyLinkLog

Begin Sequence

   EYF->(DbSetOrder(1))
   If EYF->(DbSeek(xFilial()+::cIDEv))
      EYF->(RecLock("EYF", .F.))
      EYF->EYF_DATAF  := Date()
      EYF->EYF_HORAF  := Time()
      If ::lOkEv
         EYF->EYF_STATUS := "04"
         EYF->EYF_DESSTA := STR0023//"Contrata��o conclu�da"
      Else
         EYF->EYF_STATUS := "03"
         EYF->EYF_DESSTA := STR0022//"Contrata��o n�o concluida"
      EndIf
      EYF->(MsUnlock())
   EndIf
   aAdd(::aErros, {::cIDEv, ::cEvMsg})
   ::cEvMsg := ""

End Sequence

Return Nil

/*
M�todo      : AcMsg(cAcMsg, lOkAc)
Classe      : EasyLinkLog
Par�metros  : cAcMsg, lOkAc
Retorno     : Nenhum
Objetivos   : Adiciona uma nova mensagem na contrata��o da a��o
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method AcMsg(cAcMsg, lOkAc) Class EasyLinkLog
Default cAcMsg := ""
Default lOkAc  := .T.

If !Empty(cAcMsg)
   ::cAcMsg += ENTER + cAcMsg
EndIf
If ::lOkAc
   ::lOkAc := lOkAc
EndIf

Return Nil

/*
M�todo      : EvMsg(cEvMsg, lOkEv)
Classe      : EasyLinkLog
Par�metros  : cEvMsg, lOkEv
Retorno     : Nenhum
Objetivos   : Adiciona uma nova mensagem na contrata��o do evento
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method EvMsg(cEvMsg, lOkEv) Class EasyLinkLog
Default cEvMsg := ""
Default lOkEv  := .T.

If !Empty(cEvMsg)
   ::cEvMsg += cEvMsg
EndIf
If ::lOkEv
   ::lOkEv := lOkEv
EndIf
   
Return Nil

/*
Fun��o      : GetEnvLog()
Objetivos   : Retorna o log do ambiente no momento da execu��o da fun��o
Retorno     : cEnvLog - Conte�do do log
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Function GetEnvLog()
Local cEnvLog := ""
Local bError := ErrorBlock({|e| cEnvLog := e:ErrorEnv })

Begin Sequence
   //For�a um erro, para que a fun��o de errorlog seja chamada e a partir do objeto do erro, a vari�vel 
   //cEndLog receba o log do ambiente.
   x := 1 + "a"
End Sequence

ErrorBlock(bError)
Return cEnvLog

/*
Fun��o     : CriaDirLog
Par�metros : 
Retorno    : 
Objetivos  : Criar o diret�rio \Log\ dentro do diret�rio definido no par�metro MV_AVG0135
Autor      : wfs
Data/Hora  : 
Revisao    : 
Obs.       :
*/
*---------------------------*
Static Function CriaDirLog()
*---------------------------*
Local cDir:= EasyGParam("MV_AVG0135",,"\XML") + "\Log\"
Local lRet:= .T., nRet

Begin Sequence

    If IsSrvUNIX()
        cDir := AllTrim(Lower(StrTran(cDir, '\', '/')))//FDR - 28/08/12
    EndIf

    nRet:= MakeDir(cDir)
    
    If nRet <> 0
        lRet:= .F.        
    EndIf

End Sequence

Return lRet

Method SetLogID(cID,cIDOrigem,cRecno, aDados) Class EasyLinkLog
aAdd(::aLogID,{cID,cIDOrigem,cRecno, aDados})
Return Nil

Method GetLogID() Class EasyLinkLog
Return ::aLogID
