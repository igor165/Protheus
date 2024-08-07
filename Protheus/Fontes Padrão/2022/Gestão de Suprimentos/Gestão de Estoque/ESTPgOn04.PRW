#INCLUDE "ESTPgOn04.ch"
#include "protheus.ch"
#include "msgraphi.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ESTPgOn04� Autor � Nereu Humberto Junior � Data � 24/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Monta array para Painel de Gestao On-line Tipo 5           ���
���          � Lotes Vencidos                                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �ESTPgOn04()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Array = {bClick,aCabec,aValores)                           ���
���          � bClick = Bloco de codigo para execucao do duplo-click no   ���
���          �          browse.                                           ���
���          � aCabec = Array contendo o cabecalho             		      ���
���          � aValores = Array contendo os valores da lista              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAEST                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function  ESTPgOn04(oPGOnline,nFuncao)

Local aRet      := {}
Local nTipoData := SuperGetMV("MV_TDATALO",.F.,1)
Local dDataConf := If(nTipoData==1,dDataBase,Date())
Local aTitle    := {STR0001,STR0002,STR0003,STR0004,STR0005,STR0006,STR0007,STR0008,STR0009,STR0010,STR0011} //"Dt.Validade"###"Lote"###"Sub-Lote"###"Produto"###"Descri��o"###"Armaz�m"###"Saldo"###"Clie/Forn."###"Loja"###"Documento"###"S�rie"
Local aLotes    := {}
Local cPerg     := ""
Local dDataVenc := CTOD("")
Local cOrder    := ""
Local cAliasSB8 := 'SB8'
Local lQuery    := .F.
Local cWhere    := ''

DEFAULT nFuncao := 1
//��ESTPGON04���������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01            // Produto                     (Range)   �
//� mv_par02            // Armazem                     (Range)   �
//����������������������������������������������������������������
//��ESTPGON05���������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01            // Produto                     (Range)   �
//� mv_par02            // Armazem                     (Range)   �
//� mv_par03            // Numero de dias a vencer               �
//����������������������������������������������������������������
If nFuncao == 1 //Vencidos
	cPerg := 'ESTPGONL04'
Else // A vencer
	cPerg := 'ESTPGONL05'
Endif	

Pergunte(cPerg,.F.)
//������������������������������������������������������������Ŀ
//�Converte os parametros do tipo range, para um range cheio,  �
//�caso o conteudo do parametro esteja vazio                   �
//��������������������������������������������������������������
FullRange(cPerg)

If nFuncao == 2 //A vencer
	dDataVenc := dDatabase+IIF(Empty(mv_par03),30,mv_par03)
	If Valtype(oPGOnline) == "O"
		oPGOnline:SetDescr(STR0012+Alltrim(Str(mv_par03))+STR0013) //"Lotes a vencer em "##" dias"
	Endif	
Endif

dbSelectArea("SB8")
dbSetOrder(1)

	cAliasSB8 := GetNextAlias()	
	lQuery    := .T.
	//������������������������������������������������������������������������Ŀ
	//�Transforma parametros Range em expressao SQL                            �
	//��������������������������������������������������������������������������
	MakeSqlExpr(cPerg)
	mv_par01 := '%'+mv_par01+'%'
	mv_par02 := '%'+mv_par02+'%'
	
	cWhere := "%"
    If nFuncao == 1
    	cWhere+=" AND SB8.B8_DTVALID < '" + %Exp:Dtos(dDataConf)%+ "'"
	Else
		cWhere+=" AND SB8.B8_DTVALID >= '" + %Exp:Dtos(dDataConf)%+ "'"
		cWhere+=" AND SB8.B8_DTVALID <= '" + %Exp:Dtos(dDataVenc)%+ "'"
	Endif    
	cWhere += "%"
	
	cOrder := "% B8_FILIAL,B8_DTVALID,B8_PRODUTO,B8_LOTECTL,B8_NUMLOTE,B8_LOCAL  %"

	BeginSql Alias cAliasSB8

		SELECT SB8.B8_PRODUTO, SB8.B8_LOCAL, SB8.B8_LOTECTL, SB8.B8_NUMLOTE, SB8.B8_DTVALID, SB8.B8_SALDO, 
		SB8.B8_CLIFOR, SB8.B8_LOJA, SB8.B8_DOC, SB8.B8_SERIE

		FROM %Table:SB8% SB8
	
		WHERE SB8.B8_FILIAL = %xFilial:SB8%
   		      AND %Exp:mv_par01%
   		      AND %Exp:mv_par02%
   		      AND SB8.B8_SALDO > 0
   		      %Exp:cWhere%
   		      AND SB8.%NotDel%

		ORDER BY %Exp:cOrder%
			
	EndSql


While (cAliasSB8)->(!Eof())
	
	SB1->(MsSeek(xFilial("SB1")+(cAliasSB8)->B8_PRODUTO))
	
	(cAliasSB8)->(Aadd(aLotes, {IIF(lQuery,STOD(B8_DTVALID),B8_DTVALID),B8_LOTECTL, B8_NUMLOTE, B8_PRODUTO,;
	              SB1->B1_DESC,B8_LOCAL,AllTrim(Trans(B8_SALDO,PesqPictQt("B8_SALDO"))),B8_CLIFOR,;
	              B8_LOJA,B8_DOC,AllTrim(SubStr(B8_SERIE,1,3))}))
	
	(cAliasSB8)->(dbSkip())
EndDo

If Len(aLotes) == 0
	aLotes := {{"","","","","","","","","","",""}}
Endif
//������������������������������������������������������������������������Ŀ
//�Preenche array do Painel de Gestao tipo 5 - Browse                      �
//��������������������������������������������������������������������������

aRet := {/*{|x| bClick}*/,aTitle,aLotes}

dbSelectArea(cAliasSB8)
DbCloseArea()

dbSelectArea("SB8")
dbSetOrder(1)

Return aRet