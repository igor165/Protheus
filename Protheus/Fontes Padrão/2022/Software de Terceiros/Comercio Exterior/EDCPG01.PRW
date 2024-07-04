#include "protheus.ch"
#include "msgraphi.ch"  
#include "edcpg01.ch"

********************************************************************************************************
Function EDCPG01()
********************************************************************************************************

 Private cText       := ""                    ,;
         cValor      := "0"                   ,;
         nColorValor := NIL                   ,; 
         bClick      := NIL                   ,;
         cPicSaldos  := AvSX3("ED1_VALORI",6)

   // cText       : Texto da Coluna 
   // cValor      : Valor a ser exibido ( String ), já com a picture aplicada. 
   // nColorValor : Cor do Valor no Formato RGB ( Opcional ) 
   // bClick      : Bloco de código a ser  executado no click do valor  ( Opcional ) 

Return EDCPG01Proc()


********************************************************************************************************
Static Function EDCPG01Proc()
********************************************************************************************************

 Local aRetPanel := {}                ,;
       nIndicad1 := 0                 ,;
       nIndicad2 := 0                 ,;
       nIndicad3 := 0                 ,;
       nIndicad4 := 0                 ,;
       cFilED0     := xFilial("ED0")

 Private cFilED3 := xFilial("ED3")  ,;
         cFilED4 := xFilial("ED4")

   ChkFile("ED0")
   ChkFile("ED3")
   ChkFile("ED4")

   ED0->( DBSetOrder(2) )
   ED0->( DBSeek(cFilED0) )
   ED3->( DBSetOrder(1) )
   ED4->( DBSetOrder(1) )
   Do While ED0->( !EoF()  .And.  ED0_FILIAL == cFilED0 )
      nIndicad1 := EDCPG01Ped(nIndicad1)
      nIndicad2 := EDCPG01Ato(nIndicad2)
      nIndicad3 := EDCPG01Imp(nIndicad3)
      nIndicad4 := EDCPG01Exp(nIndicad4)
      ED0->( DBSkip() )
   EndDo

   AAdd( aRetPanel, EDCPG01_01(nIndicad1) )
   AAdd( aRetPanel, EDCPG01_02(nIndicad2) )
   AAdd( aRetPanel, EDCPG01_03(nIndicad3) )
   AAdd( aRetPanel, EDCPG01_04(nIndicad4) )

Return aRetPanel


********************************************************************************************************
Static Function EDCPG01Ped(nQuantidade)
********************************************************************************************************

   nQuantidade += 1

Return nQuantidade


********************************************************************************************************
Static Function EDCPG01Ato(nQuantidade)
********************************************************************************************************

   If !Empty(ED0->ED0_AC)
      nQuantidade += 1
   EndIf

Return nQuantidade


********************************************************************************************************
Static Function EDCPG01Imp(nValor)
********************************************************************************************************

 Local cChave := cFilED4+ED0->ED0_PD

   If !Empty(ED0->ED0_AC)  .And.  Empty(ED0->ED0_DT_ENC)
      ED4->( DBSeek(cChave) )
      Do While ED4->( !EoF()  .And.  ED4_FILIAL+ED4_PD == cChave )
         nValor += ED4->ED4_VL_LI
         ED4->( DBSkip() )
      EndDo
   EndIf

Return nValor


********************************************************************************************************
Static Function EDCPG01Exp(nValor)
********************************************************************************************************

 Local cChave := cFilED3+ED0->ED0_PD

   If !Empty(ED0->ED0_AC)  .And.  Empty(ED0->ED0_DT_ENC)
      ED3->( DBSeek(cChave) )
      Do While ED3->( !EoF()  .And.  ED3_FILIAL+ED3_PD == cChave )
         nValor += ED3->( ED3_SAL_CO + ED3_SAL_SE )
         ED3->( DBSkip() )
      EndDo
   EndIf

Return nValor


********************************************************************************************************
Static Function EDCPG01_01(nValor)
********************************************************************************************************

 Local aIndicador := {}

   cText       := STR0001 //"Pedidos Confeccionados"
   cValor      := "0"
   nColorValor := NIL
   bClick      := "{ || MsgInfo('"+STR0002+"') }" //"Quantidade de Pedidos de Drawback confeccionados."

   cValor := AllTrim( Str(nValor) )
    
   aIndicador := { cText, cValor, nColorValor, bClick }

Return aIndicador


********************************************************************************************************
Static Function EDCPG01_02(nValor)
********************************************************************************************************

 Local aIndicador := {}

   cText       := STR0003 //"Atos Aprovados"
   cValor      := "0"
   nColorValor := CLR_GREEN
   bClick      := "{ || MsgInfo('"+STR0004+"') }" //"Quantidade de Atos Concessórios aprovados."

   cValor := AllTrim( Str(nValor) )
    
   aIndicador := { cText, cValor, nColorValor, bClick }

Return aIndicador


********************************************************************************************************
Static Function EDCPG01_03(nValor)
********************************************************************************************************

 Local aIndicador := {}

   cText       := STR0005+STR0009 //"Saldo a Importar"+" (em US$) "
   cValor      := "0"
   nColorValor := CLR_BLUE
   bClick      := "{ || MsgInfo('"+STR0006+"') }" //"Soma dos saldos a importar em Drawback em Dólar Americano."

   cValor := Transform( nValor, cPicSaldos )
    
   aIndicador := { cText, cValor, nColorValor, bClick }

Return aIndicador


********************************************************************************************************
Static Function EDCPG01_04(nValor)
********************************************************************************************************

 Local aIndicador := {}

   cText       := STR0007+STR0009 //"Saldo a Exportar"+" (em US$) "
   cValor      := "0"
   nColorValor := CLR_BLUE
   bClick      := "{ || MsgInfo('"+STR0008+"') }" //"Soma dos saldos a exportar em Drawback em Dólar Americano."

   cValor := Transform( nValor, cPicSaldos )
    
   aIndicador := { cText, cValor, nColorValor, bClick }

Return aIndicador