#include "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
��� Objeto     � PLS130IN   � Autor � HELIO  F. R. LECCHI  � Data � 17.10.2005 ���
������������������������������������������������������������������������������Ĵ��
��� Descri��o  � Busca qtde de internacoes para o anexo 3					   ���
������������������������������������������������������������������������������Ĵ��
��� Uso        � Advanced Protheus                                             ���
������������������������������������������������������������������������������Ĵ��
���             ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL               ���
������������������������������������������������������������������������������Ĵ��
��� Programador � Data   � BOPS �  Motivo da Altera��o                         ���
������������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
/*/
User Function PLS130IN()

Local cOper 	:= paramixb[1]
//Local cEmpIni 	:= paramixb[2]
//Local cEmpFim 	:= paramixb[3]
//Local cMatIni 	:= paramixb[4]
//Local cMatFim 	:= paramixb[5]
Local dDatIni 	:= paramixb[6]
Local dDatFim 	:= paramixb[7]
Local cGruBen 	:= paramixb[8]

Local nCir := 0
Local nCli := 0
Local nObs := 0
Local nPed := 0
Local nPsi := 0

//����������������������������������������������������������������������Ŀ
//� Totaliza valores por procedimento - Ambulatorial                     �
//������������������������������������������������������������������������

cFiltro := " SELECT BE4_GRPINT,BE4_TIPINT, COUNT(BE4_MATRIC) QTD "
cFiltro += " FROM " + RetSqlName("BE4") + ", " + RetSqlName("BA1")
cFiltro += " WHERE BE4_FILIAL = '" + xFilial("BE4") + "' AND BE4_CODOPE = '" + cOper + "' AND "
cFiltro +=       " BE4_DATPRO >= '" + DtoS(dDatIni) + "' AND BE4_DATPRO <= '" + DtoS(dDatFim) + "' AND "
cFiltro +=       " BE4_FASE = '4' AND BE4_SITUAC = '1' AND " + RetSqlName("BE4") + ".D_E_L_E_T_ <> '*' AND "
cFiltro +=       " BE4_CODOPE = BA1_CODINT AND BE4_CODEMP = BA1_CODEMP AND "
cFiltro +=       " BE4_MATRIC = BA1_MATRIC AND BE4_TIPREG = BA1_TIPREG AND "

Do Case
		//��������������������������������������������������������������������������Ŀ
		//� Beneficiarios expostos                                                   �
		//� Beneficiarios da operadora que esta enviando as informacoes e tem o      �
		//� servico fornecido majoriatariamente pela mesma                           �
		//����������������������������������������������������������������������������
	Case cGruBen == "1" // Beneficiarios expostos
		cFiltro  += " (BA1_OPEORI = '" + cOper + "' AND BA1_OPEDES = '" + cOper + "') "
		//��������������������������������������������������������������������������Ŀ
		//� Expostos nao beneficiarios                                               �
		//� Beneficiarios de outra operadora mas que tem o servico fornecido         �
		//� majoritariamente pela operadora que esta enviando as informacoes         �
		//����������������������������������������������������������������������������
	Case cGruBen == "2" // Expostos nao beneficiarios
		cFiltro  += " (BA1_OPEORI <> '" + cOper + "' AND BA1_OPEDES = '" + cOper + "') "
EndCase

cFiltro += " GROUP BY BE4_GRPINT,BE4_TIPINT "
PLSQuery(cFiltro,"BE4QRY")

//��������������������������������������������������������������������������Ŀ
//� Processa as internacoes por tipo...                                      �
//����������������������������������������������������������������������������

While ! BE4QRY->(Eof())

   Do Case
      Case BE4QRY->BE4_GRPINT == "2" // CIRURGICA
           nCir += BE4QRY->QTD
      Case BE4QRY->BE4_GRPINT == "1" .and. BE4QRY->BE4_TIPINT == "01" // CLINICA
           nCli += BE4QRY->QTD
      Case BE4QRY->BE4_GRPINT == "3" .or. ;
          (BE4QRY->BE4_GRPINT == "1" .and. BE4QRY->BE4_TIPINT == "05") // OBSTETRICA
           nObs += BE4QRY->QTD
      Case BE4QRY->BE4_GRPINT == "1" .and. BE4QRY->BE4_TIPINT == "02" // PEDIATRICA
           nPed += BE4QRY->QTD
      Case BE4QRY->BE4_GRPINT == "1" .and. BE4QRY->BE4_TIPINT == "03" // PSIQUIATRICA
           nPsi += BE4QRY->QTD
      Case BE4QRY->BE4_GRPINT == "1" // CLINICA
           nCli += BE4QRY->QTD
   EndCase        
	
   BE4QRY->(DbSkip())
Enddo

BE4QRY->(DbCloseArea())

Return({nCir,nCli,nObs,nPed,nPsi})