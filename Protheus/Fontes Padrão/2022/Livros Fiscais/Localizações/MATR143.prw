#include "PROTHEUS.CH"
#include "MATR143.CH"
#include "report.ch"

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  � MATR143   �Autor  � FSW Argentina      � Data �  11/02/11   ���
��������������������������������������������������������������������������͹��
���Desc.     � Reporte Lista de Despachos                                  ���
��������������������������������������������������������������������������͹��
���Uso       �                                        �Modulo � Compras    ���
�������������������������������������������������������������������������Ĵ��
���        ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.              ���
�������������������������������������������������������������������������Ĵ��
���Programador �Data    ?BOPS     ?Motivo da Alteracao                    ���
�������������������������������������������������������������������������Ĵ��
���Jonathan Glz�6/07/15 �PCREQ-4256�Se elimina la funcion AjustaSX1() que ���
���            �        �          �hace modificacion a SX1 por motivo de ���
���            �        �          �adecuacion a fuentes a nuevas estruc- ���
���            �        �          �turas SX para Version 12.             ���
���M.Camargo   �09.11.15�PCREQ-4262�Merge sistemico v12.1.8		          ���
���gSantacruz  �22/04/18�DMINA-2762�Se agrega la instruccion D_E_L_E_T.   ���
���            �        �          �al query.                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcion   � PrintReport� Autor � FSW Argentina         � Data � 02/12/11 ���
���������������������������������������������������������������������������Ĵ��
���Descrip.  �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
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
	Aviso(STR0001,STR0003,{STR0004})//"Relat�rio dispon�vel apenas para ambiente TopConnect." 

#ENDIF   
Return

/*/
������������������������������������������������������������������������������?
������������������������������������������������������������������������������?
���������������������������������������������������������������������������Ŀ�?
���Funcion   ?BuEstado   ?Autor �FS                     ?Data ?02/12/11 ��?
���������������������������������������������������������������������������Ĵ�?
���Descrip.  ?                                                             ��?
����������������������������������������������������������������������������ٱ?
������������������������������������������������������������������������������?
������������������������������������������������������������������������������?
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
