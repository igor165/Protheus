#include "PROTHEUS.CH"
#include "MATR143.CH"
#include "report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MATR143   ºAutor  ³ FSW Argentina      º Data ³  11/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Reporte Lista de Despachos                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                        ºModulo ³ Compras    º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³        ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ?BOPS     ?Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³6/07/15 ³PCREQ-4256³Se elimina la funcion AjustaSX1() que ³±±
±±³            ³        ³          ³hace modificacion a SX1 por motivo de ³±±
±±³            ³        ³          ³adecuacion a fuentes a nuevas estruc- ³±±
±±³            ³        ³          ³turas SX para Version 12.             ³±±
±±³M.Camargo   ³09.11.15³PCREQ-4262³Merge sistemico v12.1.8		          ³±±
±±³gSantacruz  ³22/04/18³DMINA-2762³Se agrega la instruccion D_E_L_E_T.   ³±±
±±³            ³        ³          ³al query.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MATR143()
Local oReport
Local oDBA
Local cPerg    := "MTR143"         


Pergunte(cPerg,.F.)

DEFINE REPORT oReport NAME "MATR143" TITLE STR0001 PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)}

oReport:SetLandScape()

DEFINE SECTION oDBA OF oReport TITLE STR0002 TABLES "DBA"

DEFINE CELL NAME "DBA_HAWB"   OF oDBA ALIAS "DBA" Size TamSx3("DBA_HAWB")[1]
DEFINE CELL NAME "ESTADO"     OF oDBA SIZE 	10 block {||BuEstado()}
DEFINE CELL NAME "DBA_DTRECD" OF oDBA ALIAS "DBA" Size TamSx3("DBA_DTRECD")[1]
DEFINE CELL NAME "DBA_DT_ETA" OF oDBA ALIAS "DBA" Size TamSx3("DBA_DT_ETA")[1]
DEFINE CELL NAME "DBA_PRVDES" OF oDBA ALIAS "DBA" Size TamSx3("DBA_PRVDES")[1]
DEFINE CELL NAME "DBA_DT_DTA" OF oDBA ALIAS "DBA" Size TamSx3("DBA_DT_DTA")[1]
DEFINE CELL NAME "DBA_DT_EMB" OF oDBA ALIAS "DBA" Size TamSx3("DBA_DT_EMB")[1]
DEFINE CELL NAME "DBA_DT_AVE" OF oDBA ALIAS "DBA" Size TamSx3("DBA_DT_AVE")[1]
DEFINE CELL NAME "DBA_CHEG"   OF oDBA ALIAS "DBA" Size TamSx3("DBA_CHEG")[1]
DEFINE CELL NAME "DBA_ORIGEM" OF oDBA ALIAS "DBA" Size TamSx3("DBA_ORIGEM")[1]
DEFINE CELL NAME "DBA_DEST"   OF oDBA ALIAS "DBA" Size TamSx3("DBA_DEST")[1]
DEFINE CELL NAME "DBA_PAISPR" OF oDBA ALIAS "DBA" Size TamSx3("DBA_PAISPR")[1]
DEFINE CELL NAME "DBA_IDENTV" OF oDBA ALIAS "DBA" Size TamSx3("DBA_IDENTV")[1]
DEFINE CELL NAME "DBA_VIAGEM" OF oDBA ALIAS "DBA" Size TamSx3("DBA_VIAGEM")[1]
DEFINE CELL NAME "DBA_MT3"    OF oDBA ALIAS "DBA" Size TamSx3("DBA_MT3")[1]
DEFINE CELL NAME "DBA_PESOTT" OF oDBA ALIAS "DBA" Size TamSx3("DBA_PESOTT")[1]

oReport:PrintDialog()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ PrintReport³ Autor ³ FSW Argentina         ³ Data ³ 02/12/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.  ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrintReport(oReport)
#IFDEF TOP
   Local cAlias := GetNextAlias()
   Local cSQL := ""

   IF !Empty(MV_PAR05) .AND. MV_PAR05 == 1
      cSQL += "DBA_OK = '3' AND DBA_DT_ENC <>' '" /* Si */
   ElseIF !Empty(MV_PAR05)
      cSQL += "DBA_OK <> '3' AND DBA_DT_ENC =' '" /* No */
   Else
      cSQL += "1 = 1"
   EndIF

   CSQL := "%"+CSQL+"%"

   MakeSqlExp("REPORT")

   BEGIN REPORT QUERY oReport:Section(1)

   BeginSql alias cAlias
      SELECT DBA_HAWB, DBA_DTHAWB, DBA_OK,
         DBA_DTRECD, DBA_DT_ETA, DBA_PRVDES,
         DBA_DT_DTA, DBA_DT_EMB, DBA_DT_AVE,
         DBA_CHEG, DBA_DT_ENC, DBA_ORIGEM, DBA_DEST,
         DBA_PAISPR, DBA_IDENTV, DBA_VIAGEM,
         DBA_MT3, DBA_PESOTT
      FROM %table:DBA% DBA
      WHERE DBA_HAWB BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
            AND DBA_DTHAWB BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
            AND DBA. D_E_L_E_T_ <> '*' AND %exp:cSql%
   EndSql

   END REPORT QUERY oReport:Section(1)

   oReport:Section(1):Print()     
#ELSE
	Aviso(STR0001,STR0003,{STR0004})//"Relatório disponível apenas para ambiente TopConnect." 

#ENDIF   
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Funcion   ?BuEstado   ?Autor ³FS                     ?Data ?02/12/11 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descrip.  ?                                                             ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Static Function BuEstado()
Local estado := ''

If DBA_OK== '1' .AND. Empty(DBA_DT_ENC)
      estado:= STR0005
EndIf

If DBA_OK== '2' .AND. Empty(DBA_DT_ENC)
      estado:= STR0006
EndIf

If DBA_OK== '3' .AND. Empty(DBA_DT_ENC)
   estado:= STR0007
EndIf

If DBA_OK== '3' .AND. !Empty(DBA_DT_ENC)
   estado:= STR0008
EndIf

Return estado
