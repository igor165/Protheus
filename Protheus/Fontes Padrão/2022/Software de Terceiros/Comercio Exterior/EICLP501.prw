#include 'PROTHEUS.CH'
#include 'TOTVS.CH'
#include 'FWMVCDEF.CH'
#include 'EICLP501.CH'

/*
Objetivo   : Função para realizar a atualização do modelo EICLP500 a partir de um processo de embarque já salvo
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data       : Novembro/2021
Revisão    :
*/
function EICLP501(cHawb, jModelo)
   local lRet       := .F.
   local cAliasSel  := alias()
   local oModelo    := nil
   local aAreaSW8   := {}

   default cHawb      := ""

   dbSelectArea("SW8")
   aAreaSW8 := SW8->(getArea())

   SW8->(dbSetOrder(1)) //W8_FILIAL + W8_HAWB + W8_INVOICE + W8_FORN + W8_FORLOJ
   if !empty(cHawb) .and. SW8->(dbSeek(xFilial("SW8") + cHawb ))
      LP500Atu(.T.)

      oModelo := FwLoadModel("EICLP500")
      oModelo:SetOperation(MODEL_OPERATION_UPDATE)
      oModelo:Activate()

      lRet := loadModel(oModelo, jModelo )

      if lRet
         if( oModelo:VldData(), oModelo:CommitData(), ( lRet := .F. , EasyHelp(STR0001 + CRLF + if( valtype(xError := oModelo:GetErrorMessage()) == "C", alltrim(xError), if( valtype(xError) == "A" .and. len(xError) >= 7 , CHR(10) + CHR(10) + STR0003 + ": " + allToChar( xError[6]) + CHR(10) + STR0004 + ": " + allToChar( xError[7] ) , "") ) ,STR0002,"") ) ) // "Não foi possível realizar a atualização dos Itens DUIMP" ## "Atenção" ## "Mensagem do erro" ## "Mensagem do solução"
      endif

      oModelo:DeActivate()
      oModelo:Destroy()
      FwFreeObj(oModelo)

   endif

   restArea(aAreaSW8)

   if !empty(cAliasSel)
      dbSelectArea(cAliasSel)
   endif

return lRet

/*
Objetivo   : Função para realizar a atualização do modelo EICLP500 com base no json
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data       : Novembro/2021
Revisão    :
*/
static function loadModel(oModelo, jModelo)
   local lRet       := .T.
   local aNames     := {}
   local oModSW9    := nil
   local nLine      := 0
   local jModelSW9  := nil
   local cChave     := ""
   local lSeek      := .F.

   if valtype(jModelo) == "J"

      aNames := jModelo:getnames()
      if aScan( aNames , { |X| X == "SW9DETAIL" } ) > 0

         oModSW9 := oModelo:getModel("SW9DETAIL")
         if LP500SeqD(oModelo, oModSW9)
            lRet := MsgYesNo( STR0005 ) // "Foram identificados itens com a sequência da DUIMP informada. Deseja sobrescrever estas informações?"
            if lRet
               LP500ClrSq()
            endif
         endif

         if lRet 

            for nLine := 1 to len(jModelo["SW9DETAIL"])

               jModelSW9 := jModelo["SW9DETAIL"][nLine]

               if valtype(jModelSW9) == "J"
                  aNames := jModelSW9:getnames()
                  lRet := setModel("", oModelo, "SW9DETAIL", oModSW9, jModelSW9, aNames, @cChave, @lSeek )

                  if lRet .and. lSeek .and. aScan( aNames , { |X| X == "RELACIONAMENTOS" } ) > 0
                     lRet := len(jModelSW9["RELACIONAMENTOS"]) == 0 .or. setRelations(oModelo, "SW9DETAIL", jModelSW9["RELACIONAMENTOS"] )
                     if !lRet
                        exit
                     endif
                  endif

               endif

            next

            // para executar o método VldData
            lRet := .T.

         endif

      endif

   endif

return lRet

/*
Objetivo   : Função para realizar o set dos modelos relacionados
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data       : Novembro/2021
Revisão    :
*/
static function setRelations(oModPai, cModSup, aRelations )
   local lRet       := .F.
   local nRel       := 0
   local jRelation  := nil
   local aNames     := {}
   local nModRel    := 0
   local cModelo    := ""
   local oModRel    := nil
   local jModelRel  := nil
   local nModelos    := 0

   default aRelations := {}

   begin sequence

   for nRel := 1 to len( aRelations )

      jRelation := aRelations[nRel]
      aNames := jRelation:getnames()

      for nModRel := 1 to len( aNames )

         cModelo := aNames[nModRel]
         oModRel := oModPai:getModel(cModelo)

         if valtype(oModRel) == "O"
            jModelRel := jRelation[cModelo]
            cChave := ""
            lSeek := .F.

            for nModelos := 1 to len(jModelRel)

               jModel := jModelRel[nModelos]
               if valtype(jModel) == "J"

                  aNames := jModel:getnames()
                  lRet := setModel(cModSup, oModPai, cModelo, oModRel, jModel, aNames, @cChave, @lSeek )

                  if lRet .and. lSeek .and. aScan( aNames , { |X| X == "RELACIONAMENTOS" } ) > 0
                     lRet := len(jModel["RELACIONAMENTOS"]) == 0 .or. setRelations(oModPai, cModelo, jModel["RELACIONAMENTOS"] )
                     if !lRet
                        break
                     endif
                  endif

               endif

            next

         endif

      next nModRel

   next nRel

   end sequence

return lRet

/*
Objetivo   : Função para realizar o posicionamnento do registros do modelo e assim realizar o setvalue
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data       : Novembro/2021
Revisão    :
*/
static function setModel(cModPai, oModPai, cModelo, oModelo, jModel, aNames, cChave, lSeek )
   local lRet       := .F.
   local aSeek      := {}

   default cModelo    := oModelo:getId()
   default aNames     := jModel:getnames()
   default cChave     := ""
   default lSeek      := .F.

   if aScan( aNames , { |X| X == "SEEK" } ) > 0 .and. aScan( aNames , { |X| X == "CHAVE" } ) > 0 .and. ( empty(cChave) .or. !(cChave == jModel["CHAVE"]) )
      cChave := jModel["CHAVE"]
      aSeek := jModel["SEEK"]
      lSeek := .F.
   endif

   if !lSeek 
      lSeek := len(aSeek) == 0 .or. ( oModelo:ClassName() == "FWFORMGRID" .and. oModelo:SeekLine(aSeek, .F., .T.) )
      lRet := lSeek
   endif

   if lSeek .and. aScan( aNames , { |X| X == "DADOS" } ) > 0
      lRet := len(jModel["DADOS"]) == 0 .or. setValue(oModelo, jModel["DADOS"])
   endif

return lRet

/*
Objetivo   : Função para realizar o setValue do modelo
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data       : Novembro/2021
Revisão    :
*/
static function setValue(oModel, aDados)
   local lRet       := .T.
   local nInf       := 0

   default aDados     := {}

   for nInf := 1 to len( aDados )
      lRet := oModel:SetValue( aDados[nInf][1], aDados[nInf][2] )
      if !lRet 
         exit
      endif
   next
 
return lRet
