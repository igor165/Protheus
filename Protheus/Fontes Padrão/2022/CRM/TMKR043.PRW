#INCLUDE "TMKR043.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMKR043  � Autor � Armando M. Tessaroli  � Data � 07/11/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio do Cen�rio de Telecobranca.	   	              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMKR043(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATMK                                                    ���
�������������������������������������������������������������������������Ĵ��
��� ANALISTA     � DATA   � BOPS �MOTIVO DA ALTERACAO                     ���
�������������������������������������������������������������������������Ĵ��
���              �        �      �                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMKR043()

Local oReport
Local aArea := GetArea()

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� Mv_Par01           // Do Grupo de Atendimento                �
//� Mv_Par02           // Ate o Grupo de Atendimento             �
//����������������������������������������������������������������
Pergunte("TMK043",.F.) 

//����������������������Ŀ
//�Interface de impressao�
//������������������������
oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )
Return

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �ReportDef �Autor  �Hanna               � Data �  26/07/06   ���
����������������������������������������������������������������������������͹��
���Desc.     �Funcao para informar as celulas que serao utilizadas no rela-  ���
���          �latorio                                                        ���
����������������������������������������������������������������������������͹��
���Uso       � TMKR043                                                       ���
����������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                            ���
����������������������������������������������������������������������������͹��
���          �        �      �                                               ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function ReportDef()
Local oReport	:= Nil						// Objeto do relatorio
Local oSection1	:= Nil						// Objeto da secao 1
Local oSection2	:= Nil						// Objeto da secao 2
Local oSection3	:= Nil						// Objeto da secao 3
Local oSection4	:= Nil						// Objeto da secao 4
Local cAlias1	:= GetNextAlias()			// Pega o proximo Alias Disponivel
Local cAlias3	:= GetNextAlias()			// Pega o proximo Alias Disponivel
Local cAlias4	:= GetNextAlias()			// Pega o proximo Alias Disponivel
Local nTamDSit	:= GetSx3Cache("ACG_DSITCB","X3_TAMANHO")

//�������������������������������������������������������������������Ŀ
//�Gera a tela com os dados para a confirma��o da geracao do relatorio�
//���������������������������������������������������������������������

//"Cen�rio de Telecobran�a"
// "Este programa ir� emitir uma rela��o dos Grupos de Atendimento e as regras que cada Grupo possui." # "A emiss�o ocorrer� baseada nos par�metros do relat�rio"
DEFINE REPORT oReport NAME "TMKR043" TITLE STR0001 PARAMETER "TMK043" ACTION {|oReport| Tkr043PrtRpt(oReport, cAlias1, cAlias3, cAlias4)} DESCRIPTION STR0002 + STR0003

//�����������������������������Ŀ
//�Define a secao1 do relatorio �
//�������������������������������
DEFINE SECTION oSection1 OF oReport TITLE STR0039 TABLES "SU0","SK0","SK2" COLUMNS 2		// "Detalhes do Grupo de Atendimento"

//���������������������������������������������Ŀ
//�Define as celulas que irao aparecer na secao1�
//�����������������������������������������������
DEFINE CELL NAME "GRPATEND"		OF oSection1 SIZE 20 PICTURE "@!" TITLE STR0007
DEFINE CELL NAME "U0_CODIGO"	OF oSection1 ALIAS "SU0" TITLE StrTran(STR0008,":","")
DEFINE CELL NAME "U0_NOME" 		OF oSection1 ALIAS "SU0" TITLE StrTran(STR0009,":","")
DEFINE CELL NAME "U0_REGSEL" 	OF oSection1 ALIAS "SU0" TITLE StrTran(STR0010,":","")
DEFINE CELL NAME "K0_DESC" 		OF oSection1 ALIAS "SK0" TITLE StrTran(STR0011,":","")
DEFINE CELL NAME "U0_REGNEG" 	OF oSection1 ALIAS "SU0" TITLE StrTran(STR0012,":","")
DEFINE CELL NAME "K2_DESC" 		OF oSection1 ALIAS "SK2" TITLE StrTran(STR0013,":","")
DEFINE CELL NAME "U0_TIPOIE" 	OF oSection1 ALIAS "SU0" TITLE StrTran(STR0014,":","")
DEFINE CELL NAME "U0_TLCMAIL" 	OF oSection1 ALIAS "SU0" TITLE StrTran(STR0015,":","")	
DEFINE CELL NAME "REGRASE"		OF oSection1 SIZE 20 PICTURE "@!" TITLE StrTran(STR0016,":","")
DEFINE CELL NAME "K0_ORDEM" 	OF oSection1 ALIAS "SK0"
DEFINE CELL NAME "K0_PRAZO" 	OF oSection1 ALIAS "SK0"
DEFINE CELL NAME "K0_PREFIXO" 	OF oSection1 ALIAS "SK0"
DEFINE CELL NAME "K0_NATUREZ" 	OF oSection1 ALIAS "SK0" 
If nTamDSit <> Nil
	DEFINE CELL NAME "DSCSITUACA" OF oSection1 TITLE StrTran(STR0021,":","") SIZE nTamDSit;
	BLOCK {|| Capital( AllTrim( Posicione("FRV",1,xFilial("FRV")+(cAlias1)->K0_SITUACA,"FRV_DESCRI") ) ) } //Situacao:
Else
	DEFINE CELL NAME "K0_SITUACA" OF oSection1 ALIAS "SK0"     
EndIf
DEFINE CELL NAME "K0_PORTADO" 	OF oSection1 ALIAS "SK0"
DEFINE CELL NAME "REGRANE"		OF oSection1 SIZE 20 PICTURE "@!" TITLE STR0023
DEFINE CELL NAME "K2_ALTTIT" 	OF oSection1 ALIAS "SK2"
DEFINE CELL NAME "K2_CREDITO" 	OF oSection1 ALIAS "SK2"
DEFINE CELL NAME "K2_SELTIT" 	OF oSection1 ALIAS "SK2"
DEFINE CELL NAME "K2_DIAREAG" 	OF oSection1 ALIAS "SK2"
DEFINE CELL NAME "K2_DIAPROR" 	OF oSection1 ALIAS "SK2"
DEFINE CELL NAME "K2_DIADESC" 	OF oSection1 ALIAS "SK2"
DEFINE CELL NAME "K2_DSCNOM" 	OF oSection1 ALIAS "SK2"
DEFINE CELL NAME "K2_DSCJUR" 	OF oSection1 ALIAS "SK2"
DEFINE CELL NAME "K2_ACRESC" 	OF oSection1 ALIAS "SK2"
DEFINE CELL NAME "K2_DECRES" 	OF oSection1 ALIAS "SK2"

//�������������������������������������������������������������������������������������Ŀ
//�Define a secao2 (que sera filha da secao1)  e o arquivo principal utilizado na secao �
//���������������������������������������������������������������������������������������
DEFINE SECTION oSection2 OF oSection1 TITLE STR0040 TABLES "SU7"	// "Operadores"
	//���������������������������������������������Ŀ
	//�Define as celulas que irao aparecer na secao2�
	//�����������������������������������������������
	DEFINE CELL NAME "U7_COD"		OF oSection2 ALIAS "SU7"
	DEFINE CELL NAME "U7_NREDUZ"	OF oSection2 ALIAS "SU7"
	DEFINE CELL NAME "U7_NOME"		OF oSection2 ALIAS "SU7"
	DEFINE CELL NAME "U7_TIPOATE"	OF oSection2 ALIAS "SU7"
	DEFINE CELL NAME "U7_REGIAO"	OF oSection2 ALIAS "SU7"
	DEFINE CELL NAME "U7_VALIDO"	OF oSection2 ALIAS "SU7"
	DEFINE CELL NAME "U7_TIPO"		OF oSection2 ALIAS "SU7"
	DEFINE CELL NAME "U7_HABIL"		OF oSection2 ALIAS "SU7"

//�������������������������������������������������������������������������������������Ŀ
//�Define a secao3 (que sera filha do oReport  e o arquivo principal utilizado na secao �
//���������������������������������������������������������������������������������������
DEFINE SECTION oSection3 OF oReport TITLE STR0041 TABLES "SX5"	// "Detalhes da promo��o de cobran�a"
	DEFINE CELL NAME "REFENCIA"		OF oSection3 SIZE 20 PICTURE "@!" TITLE STR0035
	DEFINE CELL NAME "PROMOCAO"		OF oSection3 SIZE 20 PICTURE "@!" TITLE STR0036

//�������������������������������������������������������������������������������������Ŀ
//�Define a secao3 (que sera filha da secao2)  e o arquivo principal utilizado na secao �
//���������������������������������������������������������������������������������������
DEFINE SECTION oSection4 OF oSection3 TITLE STR0042 TABLES "SK3"	// "Itens da promo�a� de cobran�a"
	DEFINE CELL NAME "K3_CODIGO"	OF oSection4 ALIAS "SK3"
	DEFINE CELL NAME "K3_DESC"		OF oSection4 ALIAS "SK3"
	DEFINE CELL NAME "K3_INICIO"	OF oSection4 ALIAS "SK3"
	DEFINE CELL NAME "K3_FINAL"		OF oSection4 ALIAS "SK3"
	DEFINE CELL NAME "K3_VCTINI"	OF oSection4 ALIAS "SK3"
	DEFINE CELL NAME "K3_VCTFIM"	OF oSection4 ALIAS "SK3"
	DEFINE CELL NAME "K3_DIADESC"	OF oSection4 ALIAS "SK3"
	DEFINE CELL NAME "K3_DSCNOM"	OF oSection4 ALIAS "SK3"
	DEFINE CELL NAME "K3_DSCJUR"	OF oSection4 ALIAS "SK3"

//��������������������������������������������������������������������������������������
//�Pula pagina quando houver a quebra da secao e define a secao 1, com estilo enchoice �
//��������������������������������������������������������������������������������������
oSection3:SetPageBreak(.T.) 
oSection1:SetLineStyle()
oSection3:SetLineStyle()
Return oReport

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �TKR043PrtRpt�Autor  �Hanna               � Data �  27/07/06   ���
���������������������������������������������������������������������������͹��
���Desc.     �Funcao para impressao do relatorio personalizavel             ���
���������������������������������������������������������������������������͹��
���Uso       � TMKR043                                                      ���
���������������������������������������������������������������������������Ĵ��
��� ANALISTA     � DATA   � BOPS �MOTIVO DA ALTERACAO                       ���
���������������������������������������������������������������������������Ĵ��
��� Conrado Q.   �30/03/07�121875�-Faltava no SELECT o campo K3_FILIAL      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function TKR043PrtRpt( oReport,cAlias1, cAlias3, cAlias )
Local oSection1 := oReport:Section(1)				// Define a secao 1 do relatorio
Local oSection2 := oSection1:Section(1)				// Define que a secao 2 serah filha da secao 1
Local oSection3 := oReport:Section(2)				// Define que a secao 3 serah filha do objeto oReport
Local oSection4 := oSection3:Section(1)				// Define que a secao 4 serah filha do objeto oSection3

oSection1:Cell("GRPATEND"):SetCellBreak()
oSection1:Cell("U0_TLCMAIL"):SetCellBreak()
oSection1:Cell("REGRASE"):SetCellBreak()
oSection1:Cell("K0_PORTADO"):SetCellBreak()
oSection1:Cell("REGRANE"):SetCellBreak()
oSection3:Cell("REFENCIA"):SetValue( SuperGetMv( "MV_TMKSK1" ) )
oSection3:Cell("REFENCIA"):SetCellBreak()
oSection3:Cell("PROMOCAO"):SetCellBreak()


DbSelectArea("SU0")
DbSetOrder(1)
//���������������������������������������������������������������������������������Ŀ
//�Transforma parametros do tipo Range em expressao SQL para ser utilizada na query �
//�Exemplo Word, nao intervalos pre definidos (mais utilizado pelo RH - Ferias)     �
//�����������������������������������������������������������������������������������
MakeSqlExpr("TMK043")

//��������������������Ŀ
//�Inicializa a secao 1�
//����������������������
BEGIN REPORT QUERY oSection1

//������������������
//�Query da secao 1�
//������������������
BeginSql alias cAlias1
	SELECT	U0_CODIGO,	U0_NOME,	U0_REGSEL,	U0_REGNEG,	U0_TIPOIE,	U0_TLCMAIL,	K0_DESC,	
			K0_ORDEM,	K0_PRAZO,	K0_PREFIXO,	K0_NATUREZ,	K0_SITUACA,	K0_PORTADO,	K2_DESC,	
			K2_ALTTIT,	K2_CREDITO,	K2_SELTIT,	K2_DIAREAG,	K2_DIAPROR,	K2_DIADESC,	K2_DSCNOM,	
			K2_DSCJUR,	K2_ACRESC,	K2_DECRES,	U7_COD,		U7_NREDUZ,	U7_NOME,	U7_TIPOATE,	
			U7_REGIAO,	U7_VALIDO,	U7_TIPO,	U7_HABIL,	U7_POSTO

	FROM %table:SU0% SU0,	%table:SU7% SU7, %table:SK0% SK0, %table:SK2% SK2
	WHERE	U0_FILIAL	=	%xfilial:SU0%	AND
			U0_CODIGO	>=	%exp:MV_PAR01%	AND
			U0_CODIGO	<=	%exp:MV_PAR02%	AND
			U0_REGSEL	=	K0_REGSEL		AND
			U0_REGNEG	=	K2_REGNEG		AND
			U0_CODIGO	=	U7_POSTO		AND
			SU0.%notDel%					AND
			SU7.%notDel%					AND
			SK0.%notDel%					AND
			SK2.%notDel%
	ORDER BY %Order:SU0%
EndSql
	
//���������������������������������������������������������������������������Ŀ
//�Indica o fim da query, caso utilize range, deve-se informar como parametro �
//�{MV_?,MV_?} para que seja incluido no select automaticamente               �
//�����������������������������������������������������������������������������
END REPORT QUERY oSection1 //PARAM mv_par01,mv_par02
	oSection2:SetParentQuery()
oSection2:SetParentFilter({|cParam| (cAlias1)->U7_POSTO == cParam},{|| (cAlias1)->U0_CODIGO } )
//��������������������Ŀ
//�Inicializa a secao 4�
//����������������������
BEGIN REPORT QUERY oSection3
//������������������
//�Query da secao 4�
//������������������
BeginSql alias cAlias3
	SELECT	K3_FILIAL,	K3_CODIGO,	K3_DESC,	K3_INICIO,	K3_FINAL,	K3_VCTINI,
			K3_VCTFIM,	K3_DIADESC,	K3_DSCNOM,	K3_DSCJUR
	FROM %table:SK3% SK3
	WHERE	K3_FILIAL	=	%xfilial:SK3%	AND
			SK3.%notDel%
	ORDER BY %Order:SK3%
EndSql
END REPORT QUERY oSection3

oSection4:SetParentQuery()
oSection4:SetParentFilter({|cParam| (cAlias3)->K3_FILIAL == cParam},{|| (cAlias3)->K3_FILIAL } )
	
//��������������������������������������������������������������Ŀ
//�Executa a impressao dos dados, de acordo com o filtro ou query�
//����������������������������������������������������������������
oSection1:Print()
oSection3:Print()

Return