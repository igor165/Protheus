#INCLUDE "ofioc120.ch"

#include "Fileio.ch"
#include "protheus.ch"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥ OFIOC120 ≥ Autor ≥  Andre                ≥ Data ≥ 30/08/99 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Consulta Itens por Filial                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFIOC120

   Local oDlgLayOut
   local oGetH
   Local oGetD
   Local oGetT
   Local oLbHeader
   Local oLbDetail
   Local oLbTrail
   Local oBarHeader
   Local oBarDetail
   Local oBarTrail
   Local nHeader:=0

   PRIVATE oMonoAs  := TFont():New( "Mono AS", 6, 15 )
   PRIVATE oMonoAs1 := TFont():New( "Mono AS", 7, 21 )
   PRIVATE oOk      := LoadBitmap( GetResources(), "LBOK" )
   PRIVATE oNo      := LoadBitmap( GetResources(), "S4WB059N" )

   cCampo1  := Space(15)
   cCampo2  := Space(25)
   cCampo3  := Space(05)
   cCampo4  := Space(04)
   cCampo5  := Space(03)
   cCampo6  := Space(01)
   cCampo7  := Space(01)
   cCampo8  := Space(15)
   cCampo9  := Space(15)
   cCampo10 := 0
   cCampo11 := 0
   cCampo12 := 0
   cCampo13 := 0
   cCampo14 := 0
   cCampo15 := 0
   cCampo16 := 0
   cCampo17 := 0
   cCampo18 := 0
   cCampo19 := 0
   cCampo20 := 0
   cCampo21 := 0
   cCampo22 := 0
   cCampo23 := CtoD("")
   cCampo24 := CtoD("")
   cCampo25 := 0
   cCampo26 := 0
   cCampo27 := 0
   cCampo28 := 0
   cCampo29 := Space(10)
   cCampo30 := Space(10)
   cCampo31 := Space(01)
   cCampo32 := 0
   cCampo33 := 0
   cCampo34 := 0
   cCampo35 := 0

   aDsCampo := {}
   AADD(aDsCampo,STR0001)      // 01 //"Codigo     "
   AADD(aDsCampo,STR0002)      // 02 //"Descricao  "
   AADD(aDsCampo,STR0003)      // 03 //"Class ABC  "
   AADD(aDsCampo,STR0004)      // 04 //"Cod. CAI   "
   AADD(aDsCampo,STR0005)      // 05 //"Marca      "
   AADD(aDsCampo,STR0006)      // 06 //"Kit        "
   AADD(aDsCampo,STR0007)      // 07 //"Situacao   "
   AADD(aDsCampo,STR0008)      // 08 //"Nova       "
   AADD(aDsCampo,STR0009)      // 09 //"Velha      "
   AADD(aDsCampo,STR0010)      // 10 //"Venda      "
   AADD(aDsCampo,STR0011)      // 11 //"Preco      "
   AADD(aDsCampo,STR0012)      // 12 //"Reposicao  "
   AADD(aDsCampo,STR0013)      // 13 //"Garantia   "
   AADD(aDsCampo,STR0014)      // 14 //"Disponivel "
   AADD(aDsCampo,STR0015)      // 15 //"Oficina    "
   AADD(aDsCampo,STR0013)      // 16 //"Garantia   "
   AADD(aDsCampo,STR0016)      // 17 //"Bloq. Gar. "
   AADD(aDsCampo,STR0017)      // 18 //"Bloqueado  "
   AADD(aDsCampo,STR0018)      // 19 //"Consignacao"
   AADD(aDsCampo,STR0019)      // 20 //"Peca Extra "
   AADD(aDsCampo,STR0020)      // 21 //"IPI        "
   AADD(aDsCampo,STR0021)      // 22 //"Media Calc."
   AADD(aDsCampo,STR0022)      // 23 //"Ult. Venda "
   AADD(aDsCampo,STR0023)      // 24 //"Ult.Entrada"
   AADD(aDsCampo,STR0024)      // 25 //"Ult. Compra"
   AADD(aDsCampo,STR0025)      // 26 //"Custo Medio"
   AADD(aDsCampo,STR0026)      // 27 //"Qtd Embal. "
   AADD(aDsCampo,STR0027)      // 28 //"Peso       "
   AADD(aDsCampo,STR0028)      // 29 //"Locacao 1  "
   AADD(aDsCampo,STR0029)      // 30 //"Locacao 2  "
   AADD(aDsCampo,STR0030)      // 31 //"Gr Desconto"
   AADD(aDsCampo,STR0031)      // 32 //"Tributado  "
   AADD(aDsCampo,STR0032)      // 33 //"Rec. Fornec"
   AADD(aDsCampo,STR0033)      // 34 //"Rec (UP/EM)"
   AADD(aDsCampo,STR0034)      // 35 //"Em Transito"


   Lin := 008
   Pos := 005

   DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0035) FROM  01,05 TO 35,89 OF oMainWnd //"Consulta Itens por Filial"


         @ 002, 002 TO 23,331 LABEL STR0036 OF oDlg PIXEL //"Dados do Item"

         @ Lin, 005 SAY aDsCampo[1] OF oDlg PIXEL COLOR CLR_BLUE

         @ Lin, 47 MSGET oCampo1 VAR cCampo1 PICTURE "@!" OF oDlg PIXEL COLOR CLR_BLACK


         @ Lin, 139 SAY aDsCampo[2] OF oDlg PIXEL COLOR CLR_BLUE

         @ Lin, 175 MSGET oCampo2 VAR cCampo2 PICTURE "@!" OF oDlg PIXEL COLOR CLR_BLACK

         Lin := Lin + 16

         @  Lin, 002 TO Lin+21,331 LABEL STR0037 OF oDlg PIXEL //"Outras Infornmacoes"

         Lin := Lin + Pos

         @ Lin, 005 SAY aDsCampo[3] OF oDlg PIXEL COLOR CLR_BLUE

         @ Lin, 47 MSGET oCampo3 VAR cCampo3 PICTURE "@!" OF oDlg PIXEL COLOR CLR_BLACK


         @ Lin, 080 SAY aDsCampo[4] OF oDlg PIXEL COLOR CLR_BLUE

         @ Lin, 110 MSGET oCampo4 VAR cCampo4 PICTURE "@!" OF oDlg PIXEL COLOR CLR_BLACK


         @ Lin, 150 SAY aDsCampo[5] OF oDlg PIXEL COLOR CLR_BLUE

         @ Lin, 180 MSGET oCampo5 VAR cCampo5 PICTURE "@!" OF oDlg PIXEL COLOR CLR_BLACK


         @ Lin, 215 SAY aDsCampo[6] OF oDlg PIXEL COLOR CLR_BLUE

         @ Lin, 230 MSGET oCampo6 VAR cCampo6 PICTURE "@!" OF oDlg PIXEL COLOR CLR_BLACK


         @ Lin, 250 SAY aDsCampo[7] OF oDlg PIXEL COLOR CLR_BLUE

         @ Lin, 280 MSGET oCampo7 VAR cCampo7 PICTURE "@!" OF oDlg PIXEL COLOR CLR_BLACK

         Lin := Lin + 16

         @  Lin, 002 TO Lin+21,331 LABEL STR0038 OF oDlg PIXEL //"Substituicao"

         Lin := Lin + Pos


         @ Lin, 005 SAY aDsCampo[8] OF oDlg PIXEL COLOR CLR_BLUE

         @ Lin, 047 MSGET oCampo8 VAR cCampo8 PICTURE "@!" OF oDlg PIXEL COLOR CLR_BLACK


         @ Lin, 150 SAY aDsCampo[9] OF oDlg PIXEL COLOR CLR_BLUE

         @ Lin, 200 MSGET oCampo9 VAR cCampo9 PICTURE "@!" OF oDlg PIXEL COLOR CLR_BLACK


         Lin := Lin + 16

         @  Lin, 002 TO Lin+28,331 LABEL STR0039 OF oDlg PIXEL //"Valores"

         Lin := Lin + Pos


         @ Lin, 005 SAY aDsCampo[10] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 080 SAY aDsCampo[11] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 160 SAY aDsCampo[12] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 230 SAY aDsCampo[13] OF oDlg PIXEL COLOR CLR_BLUE

         Lin := Lin + Pos + 3

         @ Lin, 005 MSGET oCampo10 VAR cCampo10 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK
         @ Lin, 080 MSGET oCampo11 VAR cCampo11 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK
         @ Lin, 160 MSGET oCampo12 VAR cCampo12 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK
         @ Lin, 230 MSGET oCampo13 VAR cCampo13 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK


         Lin := Lin + 16

         @  Lin, 002 TO Lin+46,331 LABEL STR0040 OF oDlg PIXEL //"Estoque"

         Lin := Lin + Pos

         @ Lin, 005 SAY aDsCampo[14] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 047 MSGET oCampo14 VAR cCampo14 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK
         @ Lin, 109 SAY aDsCampo[17] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 145 MSGET oCampo17 VAR cCampo17 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK
         @ Lin, 205 SAY aDsCampo[20] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 255 MSGET oCampo20 VAR cCampo20 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK

         Lin := Lin + Pos + 07

         @ Lin, 005 SAY aDsCampo[15] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 047 MSGET oCampo15 VAR cCampo15 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK
         @ Lin, 109 SAY aDsCampo[18] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 145 MSGET oCampo18 VAR cCampo18 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK
         @ Lin, 205 SAY aDsCampo[21] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 255 MSGET oCampo21 VAR cCampo21 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK

         Lin := Lin + Pos + 07

         @ Lin, 005 SAY aDsCampo[16] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 047 MSGET oCampo16 VAR cCampo16 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK
         @ Lin, 109 SAY aDsCampo[19] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 145 MSGET oCampo19 VAR cCampo19 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK
         @ Lin, 205 SAY aDsCampo[22] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 255 MSGET oCampo22 VAR cCampo22 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK

         Lin := Lin + 18

         @  Lin, 002 TO Lin+68,331 LABEL STR0041 OF oDlg PIXEL //"Informacoes Complementares"

         Lin := Lin + Pos

         @ Lin, 005 SAY aDsCampo[23] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 080 SAY aDsCampo[24] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 160 SAY aDsCampo[25] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 230 SAY aDsCampo[26] OF oDlg PIXEL COLOR CLR_BLUE

         Lin := Lin + Pos + 3

         @ Lin, 005 MSGET oCampo23 VAR cCampo23 PICTURE "@D" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK
         @ Lin, 080 MSGET oCampo24 VAR cCampo24 PICTURE "@D" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK
         @ Lin, 160 MSGET oCampo25 VAR cCampo25 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK
         @ Lin, 230 MSGET oCampo26 VAR cCampo26 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK

         Lin := Lin + Pos + 10

         @ Lin, 005 SAY aDsCampo[27] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 047 MSGET oCampo27 VAR cCampo27 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK
         @ Lin, 109 SAY aDsCampo[28] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 145 MSGET oCampo28 VAR cCampo28 PICTURE "@!" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK
         @ Lin, 205 SAY aDsCampo[29] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 255 MSGET oCampo29 VAR cCampo29 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK

         Lin := Lin + Pos + 07

         @ Lin, 005 SAY aDsCampo[30] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 047 MSGET oCampo30 VAR cCampo30 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK
         @ Lin, 109 SAY aDsCampo[31] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 145 MSGET oCampo31 VAR cCampo31 PICTURE "@!" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK
         @ Lin, 205 SAY aDsCampo[32] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 255 MSGET oCampo32 VAR cCampo32 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK

         Lin := Lin + Pos + 07

         @ Lin, 005 SAY aDsCampo[33] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 047 MSGET oCampo33 VAR cCampo33 PICTURE "@!" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK
         @ Lin, 109 SAY aDsCampo[34] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 145 MSGET oCampo34 VAR cCampo34 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK
         @ Lin, 205 SAY aDsCampo[35] OF oDlg PIXEL COLOR CLR_BLUE
         @ Lin, 255 MSGET oCampo35 VAR cCampo35 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK

         aItem:={}

         AADD(aItem,{"      ","                    ","     ","     "})

         @ 210,002 LISTBOX oLbHeader FIELDS HEADER	OemToAnsi(STR0042),;   //  //"Codigo"
                      										OemToAnsi(STR0043),;   //  //"Descricao"
            	         									OemToAnsi(STR0044),;   //  //"Marca"
                        									OemToAnsi(STR0045);    // "Preco" //"Precos"
         COLSIZES 60,120,40,40;
         SIZE 290,48 OF oDlg PIXEL

         oLbHeader:SetArray(aItem)
         oLbheader:bLine := { || { aItem[oLbHeader:nAt,1] ,;
               			           aItem[oLbHeader:nAt,2] ,;
                        		 	  aItem[oLbHeader:nAt,3] ,;
                        		 	  aItem[oLbHeader:nAt,4]}}


         DEFINE SBUTTON FROM 220,295 TYPE 1 ACTION (nOpca := 1,oDlg:End());
                ENABLE OF oDlg

         DEFINE SBUTTON FROM 235,295 TYPE 3 ACTION (nOpca := 3,oDlg:End());
                ENABLE OF oDlg


   ACTIVATE MSDIALOG oDlg CENTER


Return
