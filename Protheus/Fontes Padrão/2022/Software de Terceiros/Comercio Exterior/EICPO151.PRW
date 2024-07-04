#include 'protheus.ch'
#include 'eicpo151.ch'

#define INGLES    1

/*/{Protheus.doc} PO151Imp
   Função responsável para impressão do PO utilizando POUI

   @type  Function
   @author Bruno Akyo Kubagawa
   @since 08/07/2022
   @version 1.0
   @param nenhum
   @return nil
   @example
   @see
/*/
function PO151Imp(cAlias,nReg,nOpc)
   local aArea      := {}
   local cArqAphCus := ""
   local cTipCus    := ""
   local cIdiom     := ""
   local cTitulo    := ""
   local cFile      := ""
   local cPathTemp  := ""
   local cProcesso  := ""

   default cAlias  := "SW2"
   default nReg    := SW2->(Recno())
   default nOpc    := 0

   private nIdioma   := 0 // 1 - INGLES / 0 - Corrente
   private aRegPO151 := {}

   if SW2->(!eof()) .and. SW2->(!bof())

      cTitulo := oemtoansi(FWI18NLang("EICPO151", "STR0003", 3)) // "Impressão de PO"
      cIdiom := FwRetIdiom()
      cTipCus := if( !empty(cArqAphCus),"1","0")
      aArea := SW2->(getArea())
      cPathTemp := GetTempPath()
      aRegPO151 := if(existFunc("PO150Marks"), PO150Marks(), {} )

      if FwIsInCallStack("EICPO400")
         cFile := alltrim(SW2->W2_PO_NUM)
         cProcesso := cFile
         aRegPO151 := {}
         aAdd( aRegPO151, SW2->(Recno()))
      else
         cFile := cValToChar(ThreadID()) + "_" + FWTimeStamp(4)
         cProcesso := "Impressao_PO"
      endif

      if len(aRegPO151) > 0
         cFile := "po-"+FileName(cFile)

         if selIdioma(cIdiom)
            EasyCallAph( cArqAphCus , cTitulo, "EICPO151" , .T. , cProcesso, "EICPO151" , nil , cTipCus , .F.,  cFile ) 
         endif

         FwSetIdiom(cIdiom)

         if file(cPathTemp + cFile + ".html")
            fErase(cPathTemp + cFile + ".html")
         endif

         if file(cPathTemp + cFile + ".pdf")
            fErase(cPathTemp + cFile + ".pdf")
         endif

         aRegPO151 := if(existFunc("PO150Marks"), PO150Marks(.T.), {} )
      else
         EasyHelp(STR0045, STR0046 ) // "Não foi selecionado nenhum processo para impressão." #### "Atenção"
      endif

      restArea(aArea)
   endif

return nil

/*/{Protheus.doc} FileName
   Ajusta o nome do arquivo

   @type  Function
   @author Bruno Akyo Kubagawa
   @since 08/07/2022
   @version 1.0
   @param nenhum
   @return nil
   @example
   @see
/*/
static function FileName(cFileName)
   local cFile := ""

   default cFileName := ""

   cFile := strTran(cFileName, "\", "")
   cFile := strTran(cFile, "/", "")
   cFile := strTran(cFile, "|", "")
   cFile := strTran(cFile, "<", "")
   cFile := strTran(cFile, ">", "")
   cFile := strTran(cFile, "*", "")
   cFile := strTran(cFile, ":", "")
   cFile := strTran(cFile, '"', '')
   cFile := strTran(cFile, "'", "")
   cFile := strTran(cFile, ":", "")

return alltrim(cFile)

/*/{Protheus.doc} selIdioma
   Função responsável pela seleção do idioma do relatório

   @type  Function
   @author Bruno Akyo Kubagawa
   @since 08/07/2022
   @version 1.0
   @param nenhum
   @return nil
   @example
   @see
/*/
static function selIdioma(cIdiom)
   local lRet       := .F.
   local oDlg       := nil
   local nOpc       := 0
   local bConfirmar := { || nOpc := 1 , oDlg:DeActivate() }
   local oPanel     := nil
   local nRadio     := 0
   local aItems     := {}
   local oRadio     := nil

   default cIdiom := FwRetIdiom()

   oDlg := FWDialogModal():New()       
   oDlg:setEscClose(.F.)
   oDlg:setTitle(STR0004) // "Selecione o idioma para impressão do relatório"
   oDlg:setSize(100, 170)
   oDlg:createDialog()
   oDlg:addButton(STR0005, bConfirmar, STR0005, , .T., .F., .T., ) // "Confirmar"
   oDlg:addButton(STR0006, {|| oDlg:DeActivate()  },STR0006,,.T.,.F.,.T.) // "Cancelar"

   oPanel := TPanel():New( ,,, oDlg:getPanelMain() )
   oPanel:Align := CONTROL_ALIGN_ALLCLIENT
   
   TSay():New(05,05,{|| STR0007 + ":"}, oPanel,,,,,,.T.,,,100,12,,,,,,.T.) // "Idioma"

   nRadio := 1
   aItems := {STR0008, STR0009 } // "Inglês" #### Idioma Corrente" 
   oRadio := TRadMenu():New (15,05,aItems,,oPanel,,,,,,,,100,12,,,,.T.)
   oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}

   oDlg:Activate()

   lRet := nOpc == 1
   if lRet
      if nRadio == 1 .and. !alltrim(upper(cIdiom)) == "EN"// ingles
         FwSetIdiom('en   ')
      endif

      if nRadio == 1 .Or. alltrim(upper(cIdiom)) == "EN"
         nIdioma := INGLES
      endif

   endif

   FwFreeObj(oDlg)

return lRet
