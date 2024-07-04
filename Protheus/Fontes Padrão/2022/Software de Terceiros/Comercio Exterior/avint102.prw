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
Objetivo   : Reúne as classes EasyLink e EasyLinkLog
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Obs        : 
*/

/*
Classe      : EasyLink
Objetivos   : Fazer a leitura e tradução de arquivos XML de serviços.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     : 
Obs.        : 
*/
*=============*
Class EasyLink
*=============*

//*** Informações do serviço
Data cInt
Data cAction
Data cService
Data cDir
Data cFile
//***

//*** Informações da contratação
Data dData
Data cHora
//***

//*** Áreas de dados temporárias
Data aFilesExt //Armazena os arquivos XML externos utilizados no serviço durante a tradução
Data aTempMem  //Aloca variáveis que não podem ser armazenadas na propriedade "TEXT" das tags (Ex. Objetos)
//***

//*** Controle de mensagens de erro e avisos
Data cError
Data cWarning
//***

//*** Controles da estrutura do layout do serviço
Data lOkStruct
Data lExtOpened
Data aAtts
Data aAuxAtts
Data aCmds
Data lInsertFields
//***

//*** Armazena o layout do serviço (XML) quando carregado na memória
Data oService
//***

//*** Controla as estruturas de repetição
Data nWhile
Data nFor
Data aForVars
Data lLoop
Data lExit
//***

//*** Aloca dados temporáios criados pelo layout do XML
Data aVars
//***

//***
Method New(cInt, cAction, cService, cNomXml, dData, cHora) Constructor
//***

//*** Métodos utilizados na abertura do layout do serviço e de arquivos XML externos
Method __ReadXML()
Method OpenExtRef(cFile)
Method __XMLJoin(cFileFrom, cFileTo)
//***

//***  Métodos utilizados na leitura do layout e busca das definições das tags no dicionário de tags
Method ReadService(oXML)
Method ChkStructure(oTag, lSetNodPai)
Method SetAtributes(oTag)
Method GetDicProps(oTag)
//***

//*** Métodos utilizados para busca de tags e/ou conteúdo e definições das mesmas
Method NodInf(oNod, cInf)
Method SearchNod(cNod, cRet, oNod, lSearchAll, _nNivel, _nNivelMax, cAtt, cType, __aNod)
Method Split(cNodes)
Method RetContent(oTag)
Method BackupNod(oNod, oBackup, lRemoveControls, lCopyRoot, aNotCopy, lValidAll, __nNivel)
Method ChkInfo(oNod)
//***

//*** Métodos utilizados na tradução do conteúdo do layout
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

//*** Métodos auxiliares na alocação de dados na memória no conteúdo do layout
Method NewVar(cVar, xData)
Method SetVar(cVar, xData)
Method RetVar(cVar)
//***

//*** Métodos utilizados no envio e recebimento das informações traduzidas
Method Send()
Method Receive()
Method RetMsg()
//***

End Class


/*
Método      : New
Classe      : EasyLink
Parâmetros  : cInt, cAction, cService, cNomXml, dData, cHora
Retorno     : Self
Objetivos   : Retornar uma nova instância da classe EasyLink.
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
If !Empty(cNomXML) .And. !At(".APH", Upper(cNomXML)) > 0//RMD - 16/01/15 - Possibilita a gravação do XML em um arquivo APH
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
Método      : ReadService
Classe      : EasyLink
Parâmetros  : oXML - Opcional - Objeto XML onde será feita a leitura. Por padrão, lê o arquivo XML definido nas propriedades do serviço
Retorno     : lRet - Indica se a leitura foi concluída
Objetivos   : Faz a leitura do arquivo XML do serviço e verifica sua estrutura
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
      ::cError := STR0004 + ENTER;//"Não foi possível ler o arquivo XML do serviço."
                  + STR0005 + ::cError//"Erro encontrado:"
      lRet := .F.
      Break
   EndIf
   
   If !(::SearchNod("SERVICE",, oXML:_EASYLINK))
      ::cError := STR0004 + ENTER;//"Não foi possível ler o arquivo XML do serviço."
                  + STR0006 + ::cError//"Foram encontrados erros na estrutura do XML."
      lRet := .F.
      Break
   EndIf
   
   //Verifica se o arquivo XML possui um ou mais serviços
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
         ::cError += STR0007 + "(" + ::cService + ")"//"O serviço não foi encontrado"
         lRet := .F.

      Case nFound == 1
         
         //Verifica se existem referências a arquivos XML externos.
         If !::lExtOpened .And. ::SearchNod("XMLEX",, oXML) .And. !Empty(oXML:_XMLEX:TEXT)
            //Reabre o arquivo XML já contendo o XML externo em seu conteúdo e recomeça a leitura do serviço
            //Utiliza macro porque a estrutura do arquivo ainda não foi verificada, portanto o método 'RetContent' não irá traduzir o conteúdo
            oXML := ::OpenExtRef(&(oXML:_XMLEX:TEXT))
            If Empty(::cError)
               ::lExtOpened := .T.
               Return ::ReadService(oXML)
            Else
               lRet := .F.
               Break
            EndIf
         EndIf
         
         //Verifica se as referências a campos devem ser atualizadas na base de dados
         If ValType(oInsert := ::SearchNod("INSERT_FIELDS", "SELF", oXML, .F.)) == "O" .And. ValType(oInsert := ::SearchNod(":ACTIVATED", "SELF", oInsert, .F.)) == "O" .And. oInsert:Text $ cSim
            ::lInsertFields := .T.
         EndIf
         
         //Verifica se possui a estrutura obrigatória DATA_SEND
         If !(::SearchNod("DATA_SEND",, oXML, .F.))
            ::cError += STR0008//"Erro na estrutura do XML. A Tag <DATA_SEND> não foi encontrada ou está posicionada em local inválido."
         EndIf

         ::ChkStructure(oXml:_DATA_SEND)
        
         //Verifica as estruturas complementares
         If ::SearchNod("DATA_SELECTION",, oXML)
            ::ChkStructure(oXml:_DATA_SELECTION)
         EndIf
         If ::SearchNod("DATA_RECEIVE",, oXML)
            ::ChkStructure(oXml:_DATA_RECEIVE)
         EndIf
         //Caso tenha encontrado erros nas verificações acima, os mesmos estarão armazenados na propriedade cError
         If !Empty(::cError)
            lRet := .F.
            Break
         EndIf

         ::oService := oXml
     
      OtherWise
         ::cError += STR0009//"Erro na estrutura do XML. Foi encontrada mais de uma ocorrência ao mesmo serviço"
   EndCase
   ::lOkStruct := lRet

End Sequence

Return lRet

/*
Método      : ReadXml
Classe      : EasyLink
Objetivos   : Auxiliar ao método ReadService, faz a conversão do arquivo XML em um objeto
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Method __ReadXML() Class EasyLink
Local oFile
Local cXML

//RMD - 16/01/15 - Possibilita a gravação do XML em um arquivo APH
If At(".APH", Upper(::cFile)) > 0
   cXML := &("H_" + AllTrim(StrTran(Upper(::cFile), ".APH", "")) + "()")
   oFile := XmlParser(cXML , "_" , ::cError , ::cWarning )
ElseIf File(::cFile)
   oFile := XmlParserFile(::cFile , "_" , ::cError , ::cWarning )
Else
   ::cError += STR0010 + "(" + AllTrim(::cFile) + ")"//"O arquivo .xml do serviço não foi encontrado."
EndIf

Return oFile

/*
Método      : OpenExtRef(cFile)
Classe      : EasyLink
Parâmetros  : cFile - Caminho do arquivo externo
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
   
   //Junta o XML externo ao XML de layout do serviço e cria um novo objeto com o conteúdo da função
   cXML := ::__XMLJoin(cFile)
   oFile := XmlParser(cXML , "_" , @cError , @cWarning )
   
   If !Empty(cError)
      ::cError += "Erro na abertura do arquivo de referência ###" + ENTER
      ::cError += "Descrição: " + ENTER
      ::cError += cError + ENTER
   EndIf
   If !Empty(cWarning)
      ::cWarning += "Foram encontradas as seguintes mensagens na abertura do arquivo de referência (###)." + ENTER
      ::cWarning += "Descrição: " + ENTER
      ::cWarning += cWarning + ENTER
   EndIf
Else
   ::cError += "Erro: O serviço faz referência a um arquivo inexistente (###)" + ENTER
EndIf

Return oFile

/*
Método      : __XMLJoin(cFileFrom, cFileTo)
Classe      : EasyLink
Parâmetros  : cFileFrom - Caminho do arquivo XML externo
              cFileTo   - OPCIONAL - Caminho do arquivo de layout onde o XML será inserido. Por padrão, utiliza o XML do serviço
Retorno     : Arquivo XML resultante da junção
Objetivos   : Inserir o conteúdo de um arquivo XML dentro de outro
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
Método      : ChkStructure(oTag, lSetNodPai)
Classe      : EasyLink
Parâmetros  : oTag, lSetNodPai
Retorno     : Nenhum
Objetivos   : Adapta a estrutura do XML à estrutura entendida pelo tradutor
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
Método      : SetAtributes(oTag)
Classe      : EasyLink
Parâmetros  : oTag
Objetivos   : Informa os atributos de cada tag com base no dicionário de tags
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
            ::cError += StrTran(STR0012, "###", AllTrim(oProp:RealName))//"O atributo ### não pode ser utilizado em tags de comando."
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
Método      : GetDicProps(oTag)
Classe      : EasyLink
Parâmetros  : oTag
Retorno     : aDicPros - Array com os atributos da tag
Objetivos   : Define os atributos de uma tag com base no dicionário de tags
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
      ::cError += STR0001 + Space(1) + StrTran(STR0003, "###", xNod:RealName) + ENTER//"#Erro:" ### "A Tag ### não está cadastrada no dicionário de tags."
      Break
   EndIf

Return aDicProps

/*
Método      : Translate(oXML)
Classe      : EasyLink
Parâmetros  : oXML
Retorno     : lRet
Objetivos   : Traduz o XML, convertendo as expressões ADVLP da seção "DATA_SELECTION" do arquivo XML em dados
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
      //Verifica é um atributo interno do tradutor (neste caso não é necessária tradução)
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
Método      : TranslCmd(oXML)
Classe      : EasyLink
Parâmetros  : oXML
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
            ::cError += STR0014//"Uso de Alias não existente em tags de comando."
            lRet := .F.
            Break
         EndIf
         
      Case "SEEK" $ oNod:RealName
         DbSeek(::TranslNod(oNod, .T.))

      Case "ORDER" $ oNod:RealName
         If !Empty(cAlias)
            DbSetOrder(::TranslNod(oNod, .T.))
         Else
            ::cError += STR0013//"Alias não definido no uso de tags de comando."
            lRet := .F.
            Break
         EndIf

      Case "IF" $ oNod:RealName
         If !::SearchNod(":COND",, oNod, .F.)
            ::cError += "Erro: A tag IF posicionada abaixo da tag ### possui condição inválida ou inexistente."
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
            ::cError += "Erro: A tag WHILE posicionada abaixo da tag ### possui condição inválida ou inexistente."
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
            ::cError := "Erro: A tag EXIT posicionada abaixo da tag ### não está relacionada a uma estrutura do tipo 'While' ou 'For'."
         Else
            ::lExit := .T.
         EndIf
         lRet := .F.
         

      Case "FOR" $ oNod:RealName
         If !::SearchNod(":INI",, oNod, .F.) .Or. !::SearchNod(":TO",, oNod, .F.)
            ::cError += "Erro: A tag FOR posicionada abaixo da tag ### não possui os atributos obrigatórios 'INI' ou 'TO'."
            lRet := .F.
            Break
         Else
            nIni := ::TranslNod(oNod:_INI, .T.)
            nTo  := ::TranslNod(oNod:_TO, .T.)
         EndIf
         If ::SearchNod(":VAR",, oNod, .F.)
            cVar := ::TranslNod(oNod:_VAR, .T.)
            If aScan(::aForVars, cVar) > 0
               ::cError += "Erro: A tag FOR posicionada abaixo da tag ### utiliza variável de contador que já está em uso em estrutura 'For' superior."
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
            ::cError := "Erro: A tag LOOP posicionada abaixo da tag ### não está relacionada a uma estrutura do tipo 'For'"
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
         ::cError += "Erro: A tag ### faz referência a uma tabela inválida na chamada do método TagReplace"
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
Método      : TranslNod(oNod)
Classe      : EasyLink
Parâmetros  : oNod
Retorno     : lRet
              lRetCont - Informa se o método deve retornar o conteúdo traduzido
Objetivos   : Traduz uma tag xml de expressão Advpl
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
   
   //Procura por recorrências a conteúdo interno na tradução e aloca em área de dados temporária   
   If !(::SetEspData(oNod, oStartTag))
      Break
   EndIf
   
   //Corrige o conteúdo quando a tag possui caracteres inválidos
   If (Asc(oNod:Text) > 1 .And. Asc(oNod:Text) < 31) .Or. (::NodInf(oNod, "TYPE") == "C" .And. Empty(oNod:Text))
      oNod:Text := ""
      Break
   EndIf

   //Se a tag for do tipo XML e não tiver conteúdo advpl, não traduz. (se executasse a tradução, retornaria Nil)
   If (::NodInf(oNod, "TYPE") == "X" .And. Empty(oNod:Text))
      Break
   EndIf
   
   //Traduz o conteúdo//LRS - 01/04/2015 - Nopado a Validação onde apresentava erro log, feito outra onde não apresenta mais erro log
   xCont := Eval({|oEasyLink| oNod:Text}, Self)
   xCont:= &xCont

   If "CMD" $ oNod:RealName
      Break
   EndIf

   /*
   Valida o resultado da tradução conforme o tipo de tag.
   São feitas as seguintes validações:
      Tags de atributo (ATT): O conteúdo deve ser sempre caractere, exceto quando o atributo pertence a uma tag de comando,
                              além disso o conteúdo nunca é validado com base no dicionário de tags.
      Tags de comando  (CMD): Não sofrem nenhum tipo de validação.
      Tags normais     (NOD): São validadas conforme o dicionário de tags.
   */
   Do Case
      Case oNod:Type == "ATT" .And. oTagPai:Type <> "CMD"
         If ValType(xCont) <> "C"
            ::cError += StrTran("A expressão do atributo ### retorna um tipo de dado diferente de caractere.", "###", AllTrim(oNod:RealName))
            Break
         EndIf

      Case oNod:Type == "NOD"
         If !(ValType(xCont) $ ::NodInf(oNod, "TYPE"))
            ::cError += StrTran(STR0016, "###", AllTrim(oNod:RealName)) + ENTER +;//"A expressão da tag ### retorna um tipo de dado diferente do definido."
                        "A expressão retornou um dado do tipo '" + ValType(xCont) + "' e era esperado o tipo '" + ::NodInf(oNod, "TYPE") + "'"
            Break
         EndIf

   End Case
   
   If lRetCont
      Break
   EndIf
   
   If oNod:Type == "NOD" .Or. (oNod:Type == "ATT" .And. oTagPai:Type <> "CMD")
      //Insere o conteúdo no campo correspondente
      If ::lInsertFields .And. ValType(cField := ::SearchNod(":ISFIELD", "TEXT", oNod, .F.)) == "C" .And. cField $ cSim
         &(oNod:RealName) := xCont
      EndIf
      //Adapta o conteúdo traduzido para ser armazenado na TAG
      Do Case
         Case ValType(xCont) == "C" .And. oNod:Type == "ATT"
            //Nos atributos o conteúdo é sempre armazenado entre aspas
            xCont := "'" + xCont + "'"
         Case ValType(xCont) == "N"
            xCont := Str(xCont)
         Case ValType(xCont) == "L"
            If(xCont, xCont := ".T.", xCont := ".F.")
         Case ValType(xCont) == "D"
            xCont := DToC(xCont)
         Case ValType(xCont) == "O"
            //Em caso de objetos, ele é armazenado em uma área temporária e é inserida no conteúdo da tag uma referência ao mesmo
            xCont := ::AlocTempMem(xCont)
         Case ValType(xCont) == "X"
            //Em caso de tags do tipo XML o conteúdo é avalidado somente no momento em que for requisitado
            xCont := ""
         Case ValType(xCont) == "A"
            xCont := ::AlocTempMem(xCont)
      End Case
      //Armazena o conteúdo traduzido e adaptado
      oNod:Text := xCont
   Else
      oNod:Text := cText
   EndIf
   
End Sequence

lRet := Empty(::cError)
Return If(lRetCont, xCont, lRet)

/*
Método      : AlocTempMem(xData)
Classe      : EasyLink
Parâmetros  : xData - Conteúdo que será alocado em memória temporária
Retorno     : cRef - Referência ao conteúdo na área de dados temporária
Objetivos   : Aloca um dado em uma área de dados temporária e retorna uma referência ao mesmo
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
Método      : SetEspData(oNod, oStartTag)
Classe      : EasyLink
Parâmetros  : oNod - Tag que será analisada
              oStartTag - Tag de início de busca por conteúdo interno
Retorno     : lRet
Objetivos   : Verifica se o conteúdo de uma tag possui referências a conteúdos especiais, como tags externas ou internas
              e faz os tratamentos especiais para busca deste conteúdo
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
Local aTagClass := {"N1:MESSAGE"}                                                                  //NCF - 27/11/2012 - Tag de Classe devem ser definidas para que não sejam
                                                                                                   //                   confundidas como atributos.
Begin Sequence
  
   For nInc := 1 To Len(aCmds)
      While (nPosI := At(aCmds[nInc][1], Upper(cText))) > 0
         nPosN := nPosI + Len(aCmds[nInc][1])
         If (nPosF := At("#", SubStr(cText, nPosN))) == 0
            ::cError += StrTran("Erro no uso de referências no conteúdo da tag '###'. O operador '#' não foi fechado corretamente.", "###", oNod:RealName) + ENTER
            lRet := .F.
            Break
         EndIf
         
         //Define a tag que será buscada
         cNodSearch := AllTrim(SubStr(Upper(cText), nPosN, nPosF-1))
         If aScan(aCmds, {|x| x[1] $ cNodSearch}) > 0
            lRet := .F.
            Break
         EndIf

         //NCF - 27/11/2012 - Quando a tag é de classe, deve se substituir o caracter ":" por "_"                 
         If ( nPosOcor:=aScan(aTagClass,{|x| Upper(x) $ Upper(cNodSearch)}) ) > 0
           cNodSearch := StrTran( cNodSearch , aTagClass[nPosOcor] , StrTran(aTagClass[nPosOcor],":","_") )
         EndIf 
                 
         //Verifica se está sendo feita a busca por um atributo de uma tag
         If (nPosAtt := At(":", cNodSearch)) > 0
             //Separa o nome da tag do nome do atributo
             //O atributo é armazendado da seguinte forma: ":NOME_DO_ATRIBUTO"
             cAttSearch := SubStr(cNodSearch, nPosAtt, Len(cNodSearch))
             cNodSearch := SubStr(cNodSearch, 1, nPosAtt - 1)
         EndIf
         
         If aCmds[nInc][2] == "INT"
            //Busca uma referência a algum conteúdo interno
            cData := ::GetIntData(cNodSearch, cAttSearch, oStartTag, oNod:RealName)
         ElseIf aCmds[nInc][2] == "EXT"
            //Busca uma referência a algum conteúdo externo
            cData := ::GetExtData(cNodSearch, cAttSearch, oNod:RealName)
         ElseIf aCmds[nInc][2] == "FND"
            //Verifica a existência de uma tag no arquivo
            cData := If(::SearchNod(cNodSearch), ".T.", ".F.")
         ElseIf aCmds[nInc][2] == "FNDEX"
            cData := If(::SearchNod(cNodSearch + If(ValType(cAttSearch) == "C", cAttSearch, ""),, ::oService:_XMLEX), ".T.", ".F.")
         EndIf
         
         If ValType(cData) == "L"
           lRet := .F.
           Break
         EndIf
         
         //Inclui a referência ao conteúdo armazenado na área de dados temporária do método TranslNod
         cText := StrTran(cText, SubStr(cText, nPosI, nPosF + Len(aCmds[nInc][1])), cData)
      End Do
   Next
   If Upper(oNod:Text) <> Upper(cText)
      oNod:Text := cText
   EndIf

End Sequence

Return lRet

/*
Método      : GetIntData(cNodSearch, cAttSearch, oStartTag, cTag)
Classe      : EasyLink
Parâmetros  : cNodSearch - Tag a ser buscada
              cAttSearch - Atributo da tag a ser buscada
              oStartTag  - Objeto XML de início da busca
              cTag       - Nome da tag que requisitou o conteúdo
Retorno     : xRet - Referência ao conteúdo solicitado
Objetivos   : Faz a busca por um conteúdo interno da tradução e aloca este conteúdo na área de dados temporária do método TranslNod,
              retornando uma referência ao mesmo.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 27/07/2007
Revisao     :
Obs.        :
*/
Method GetIntData(cNodSearch, cAttSearch, oStartTag, cTag) Class EasyLink
Local xRet
Local cError := "", cAuxError := ""

Begin Sequence

   //Busca o conteúdo solicitado
   If ValType(xRet := ::SearchNod(cNodSearch, "TEXT", oStartTag, , , , cAttSearch)) <> "L"
      //Armazena o conteúdo na área de dados temporária
      aAdd(aIntData, xRet)
      xRet := "aIntData[" + AllTrim(Str(Len(aIntData))) + "]"
   Else
      cError += StrTran("Erro no conteúdo da tag '###'.", "###", cTag) + ENTER
      cError += StrTran("A Tag XXX não foi encontradaYYY.", "XXX", cNodSearch)
      If !Empty(cAttSearch)
         cAuxError += StrTran(" ou o atributo ### é inválido", "###", cAttSearch)
      EndIf
      cError := StrTran(cError, "YYY", cAuxError)
      xRet := .F.
      Break
   EndIf
   
End Sequence

::cError += cError

Return xRet

/*
Método      : GetExtData(cNodSearch, cAttSearch, cTag)
Classe      : EasyLink
Parâmetros  : cNodSearch - Tag a ser buscada
              cAttSearch - Atributo da tag a ser buscada
              cNod - Nome da tag que requisitou o conteúdo
Retorno     : xRet - Referência ao conteúdo externo solicitado
Objetivos   : Faz a busca por um conteúdo externo da tradução e aloca este conteúdo na área de dados temporária do método TranslNod,
              retornando uma referência ao mesmo.
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
      ::cError += StrTran("A tag '###' faz referência a uma fonte externa não declarada.", "###", cTag)
      Break
   EndIf
   
   oXMLExt := ::oService:_XMLEX
   
   If ValType(xRet := ::SearchNod(cNodSearch, "Self", oXMLExt, , , , cAttSearch)) == "L" .And. !xRet
      ::cError += StrTran("A tag '###' não foi encontrada no arquivo externo.", "###", cNodSearch + If(ValType(cAttSearch) == "C", cAttSearch, ""))
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
   
   //Armazena o conteúdo na área de dados temporária
   aAdd(aIntData, xRet)
   xRet := "aIntData[" + AllTrim(Str(Len(aIntData))) + "]"

End Sequence

Return xRet

/*
Método      : NodInf(oNod, cInf)
Classe      : EasyLink
Parâmetros  : oNod, cInf
Retorno     : xRet - Informação solicitada
Objetivos   : Retorna informações sobre a tag, com base nas informações obtidas com o dicionário de tags
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
Método      : SearchNod(cNod, cRet, oNod, lSearchAll, _nNivel, _nNivelMax)
Classe      : EasyLink
Parâmetros  : cNod - tag a ser procurada
              cRet - Opcional - Informação a ser retornada, podendo ser: RealName, Text, Self, ou nenhum (neste caso retorna valor lógico)
              oNod - Opcional - Objeto que servirá como ponto de partida para a busca
              lSearchAll - Informa se a busca será feita também nos níveis inferiores (tags contidas na tag inicial)
              _nNivel - Interno - Nível atual da busca
              _nNivelMax - Interno - Nível máximo que a busca irá atingir
              cType - Indica qual tipo de objeto está sendo buscado
              cAtt - Atributo que será retornado (da tag procurada)
Retorno     : xRet - Tag encontrada ou o conteúdo solicitado da mesma
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
      cType := "ATT"//Define que será feita a busca somente em atributos
   EndIf

   //Indica que um caminho de tags foi informado
   If At("\", cNod) > 0
      __aNod := ::Split(cNod)
      cNod := __aNod[Len(__aNod)]
   EndIf

   //Define o nível máximo de busca
   If !lSearchAll
      _nNivelMax := 1
   EndIf

   //Verifica se ultrapassou o nível máximo de busca
   If _nNivelMax > 0 .And. _nNivel > _nNivelMax
      Break
   EndIf

   If (cTipo := ValType(oNod)) == "O"
      //Verifica o caminho de tags que foi informado
      If Len(__aNod) > 0 .And. _nNivel > 0 .And. _nNivel <= Len(__aNod) .And. Upper(StrTran(oNod:RealName, ":", "_")) <> Upper(__aNod[_nNivel])
         Break
      EndIf
      //Verifica se está posicionado na tag procurada
      If Upper(oNod:RealName) == Upper(cNod)  .And. oNod:TYPE == cType//A propriedade type indica se o objeto corresponde a uma tag (TAG) ou atributo (ATT)
      //If Upper(StrTran(oNod:RealName, ":", "_")) == Upper(cNod)  .And. oNod:TYPE == cType//A propriedade type indica se o objeto corresponde a uma tag (TAG) ou atributo (ATT)
         xRet := oNod//Se encontrada a tag, encerra a busca (final das recursões)
      EndIf
   EndIf

   If ValType(xRet) == "L" .And. !xRet .And. (_nNivelMax == 0 .Or. (cTipo <> "O" .Or. _nNivel < _nNivelMax))
      If cTipo == "O"
         //Verifica o número de tags "filhas" da atual, se a mesma não for um atributo
         If oNod:Type <> "ATT"
            nChild := XmlChildCount(oNod)
         EndIf
         If (Left(Upper(oNod:RealName), 3) == "FOR" .Or. Left(Upper(oNod:RealName), 5) == "WHILE");
            .And. ValType(XmlChildEx(oNod, "_REPL")) == "O" .And. ::TranslNod(oNod:_REPL, .T.) == "1" .And. aScan(::aAuxAtts, cNod) == 0
            lInst := .T.
            aRet := {}
         EndIf
      ElseIf cTipo == "A"//É possível encontrar um "Array" de tags, que deverá ser percorrido assim como o objeto
         nChild := Len(oNod)
         aRet := {}
      Else
         //Somente chega a esta condição se ocorrer um erro, neste caso encerra a busca retornando .F.
         Break
      EndIf
      
      //Obtém o objeto das tags "filhas" da atual
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
            //Busca o atributo da tag em alargamento e somente no primeiro nível.
            If ValType(xRet) <> "A"
               xRet := ::SearchNod(cAtt, cRet, xRet,,, 1)
            Else
               aRet := {}
               For nInc := 1 To Len(xRet)
                  xRet[nInc] := ::SearchNod(cAtt, cRet, xRet[nInc],,, 1)
                  If ValType(xRet[nInc]) <> "L" .Or. xRet[nInc]                    //NCF - 15/08/2012 - Verificação da variável xRet como array e não como lógica
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
Método      : RetContent(oTag)
Classe      : EasyLink
Parâmetros  : oTag
Retorno     : xContent - Conteúdo da tag
Objetivos   : Retorna o conteúdo de uma tag
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
            
            If Self:cInt <> "002"//Se a integração não for com o Inttra.
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
                  Quando a integração for com o Inttra (cód. 002), o tratamento para retorno de arrays é 
                  diferenciado, pois a idéia é retornar um array de objetos, e não um array com o conteúdo final de 
                  cada tag, como é feito na integração com o financeiro.
                  Posteriormente será necessário definir como avaliar em tempo de execução qual é a forma correta de 
                  tratar o array, para que não fique amarrado a nenhuma integração em especial.
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
Método      : BackupNod(oNod, oBackup, lRemoveControls, lCopyRoot, aNotCopy, lValidAll, __nNivel)
Classe      : EasyLink
Parâmetros  : oNod - Objeto da tag que deverá feito o backup
              oBackup - OPCIONAL - Objeto onde será feito o backup
              lRemoveControls - OPCIONAL - Indica se serão removidos todos os controle internos do XML, preparando-o para um envio externo
              lCopyRoot - OPCIONAL - Indica se o primeiro nível da tag "oNod" será copiado, caso contrário serão copiadas somente as tags filhas
              aNotCopy - OPCIONAL - Array com os tipos de tag que não devem ser copiados
              lValidAll - OPCIONAL - Define se as regras informadas em "aNotCopy" valem para todos os níveis ou somente até o primeiro
              __nNivel - INTERNO - Indica o nível da tag inicial que está sendo verificado (quantidade de recursões)
Retorno     : oBackup - Objeto contendo o backup da tag
Objetivos   : Fazer o backup de uma tag e de todo o seu conteúdo, incluindo as tags internas
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

   //Cria objeto tag para na raiz do serviço para efetuar o backup, caso a mesma não tenha sido informada
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
      //Não copia tags dos tipos informados no array aNotCopy
      If aScan(aNotCopy, oNod:Type) <> 0
         Break
      EndIf
      //Retira todas as tags e atributos específicos da tradução, "limpando" o xml para saída do sistema
      If lRemoveControls
         //Não copia os atributos que indicam o tipo de dado (relacionados em aAtts)
         //além disso, não verifica suas tags filhas (dando o break as tags filhas não são visitadas)
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
         //As tags que já foram replicadas também não são copiadas
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
      //Se a tag atual for copiada, ela se torna a tag de destino, senão ela continua sendo a indicada em oBackup
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
   
   //Obtém o objeto das tags "filhas" da atual e faz o tratamento para cada uma delas
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
Método      : ChkInfo(oNod)
Classe      : EasyLink
Parâmetros  : oNod - Objeto da tag que deverá verificada
Retorno     : lRet
Objetivos   : Verifica se o objeto da tag possui todos os atributos do dicionário de tags utilizados pelo tradutor
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
Método      : Send()
Classe      : EasyLink
Parâmetros  : Nenhum
Retorno     : lRet
Objetivos   : Envia os dados do serviço, executando os comandos da seção "DATA_SEND" do arquivo XML
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
Método      : Receive()
Classe      : EasyLink
Parâmetros  : Nenhum
Retorno     : lRet
Objetivos   : Recebe os dados do serviço, executando os comandos da seção "DATA_RECEIVE" do arquivo XML
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
         ::cError := STR0017 + ENTER + ::cError//"Erro na tradução do conteúdo da tag <DATA_RECEIVE>."
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
Método      : RetMsg()
Classe      : EasyLink
Parâmetros  : Nenhum
Retorno     : cMsg - Mensagens consolidadas
Objetivos   : Retorna as mensagens obtidas durante a leitura e tradução do XML
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
Função      : AvDefTag(cNome, cProp, cPai)
Objetivos   : Retorna as informações de uma tag conforme o dicionário de tags
Parâmetros  : cNome, cProp, cPai
Retorno     : xRet - Definições da tag
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
Objetivos   : Classe de gerenciamento do log de contratações
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
Método      : New
Classe      : EasyLinkLog
Parâmetros  : cAction
Retorno     : Self
Objetivos   : Cria uma nova instância da classe e um novo registro na tabela de registro de contratações
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
   EYF->EYF_DESSTA := STR0020//"Ação não concluída"
   EYF->(MsUnlock())
   
   ::SetLogID(EYF->EYF_ID, EYF->EYF_IDORI, EYF->(Recno()), EYF->({EYF_FILIAL, EYF_DESSTA, EYF_STATUS, EYF_DATAI, EYF_HORAI, EYF_DATAF, EYF_HORAF, EYF_ARQXML, EYF_USER, EYF_ID, EYF_IDORI, EYF_NOMINT, EYF_CODINT, EYF_CODAC, EYF_DESAC, EYF_CODEVE, EYF_CODSRV}))
End Sequence

Return Self

/*
Método      : SaveLog(oEasyLink)
Classe      : EasyLinkLog
Parâmetros  : oEasyLink
Retorno     : Nenhum
Objetivos   : Grava as informações de log armazenadas no objeto em um arquivo físico
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
Método      : EndLog()
Classe      : EasyLinkLog
Parâmetros  : Nenhum
Retorno     : Nenhum
Objetivos   : Grava as informações de log armazenadas no objeto em um arquivo físico
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
         EYF->EYF_DESSTA := STR0021//"Ação concluída"
      Else
         EYF->EYF_STATUS := "01"
         EYF->EYF_DESSTA := STR0020//"Ação não concluída"
      EndIf
   EndIf
   For nInc := 1 To Len(::aErros)
      cErros += ::aErros[nInc][2]
   Next

End Sequence

RestOrd(aOrd, .T.)   
Return cErros

/*
Método      : SetEvent(cInt, cEvent, cService)
Classe      : EasyLinkLog
Parâmetros  : cInt, cEvent, cService
Retorno     : Nenhum
Objetivos   : Inclui uma nova contratação de evento na ação gerenciada
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
   EYF->EYF_DESSTA := STR0022//"Contratação não concluída"
   MsUnlock()
   
   ::SetLogID(EYF->EYF_ID, EYF->EYF_IDORI, EYF->(Recno()), EYF->({EYF_FILIAL, EYF_DESSTA, EYF_STATUS, EYF_DATAI, EYF_HORAI, EYF_DATAF, EYF_HORAF, EYF_ARQXML, EYF_USER, EYF_ID, EYF_IDORI, EYF_NOMINT, EYF_CODINT, EYF_CODAC, EYF_DESAC, EYF_CODEVE, EYF_CODSRV}))
End Sequence
   
Return Nil

/*
Método      : EndEvent()
Classe      : EasyLinkLog
Parâmetros  : Nenhum
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
         EYF->EYF_DESSTA := STR0023//"Contratação concluída"
      Else
         EYF->EYF_STATUS := "03"
         EYF->EYF_DESSTA := STR0022//"Contratação não concluida"
      EndIf
      EYF->(MsUnlock())
   EndIf
   aAdd(::aErros, {::cIDEv, ::cEvMsg})
   ::cEvMsg := ""

End Sequence

Return Nil

/*
Método      : AcMsg(cAcMsg, lOkAc)
Classe      : EasyLinkLog
Parâmetros  : cAcMsg, lOkAc
Retorno     : Nenhum
Objetivos   : Adiciona uma nova mensagem na contratação da ação
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
Método      : EvMsg(cEvMsg, lOkEv)
Classe      : EasyLinkLog
Parâmetros  : cEvMsg, lOkEv
Retorno     : Nenhum
Objetivos   : Adiciona uma nova mensagem na contratação do evento
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
Função      : GetEnvLog()
Objetivos   : Retorna o log do ambiente no momento da execução da função
Retorno     : cEnvLog - Conteúdo do log
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 15/01/2007
Revisao     :
Obs.        :
*/
Function GetEnvLog()
Local cEnvLog := ""
Local bError := ErrorBlock({|e| cEnvLog := e:ErrorEnv })

Begin Sequence
   //Força um erro, para que a função de errorlog seja chamada e a partir do objeto do erro, a variável 
   //cEndLog receba o log do ambiente.
   x := 1 + "a"
End Sequence

ErrorBlock(bError)
Return cEnvLog

/*
Função     : CriaDirLog
Parâmetros : 
Retorno    : 
Objetivos  : Criar o diretório \Log\ dentro do diretório definido no parâmetro MV_AVG0135
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
