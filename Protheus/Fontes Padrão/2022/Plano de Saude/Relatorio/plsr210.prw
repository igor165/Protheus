#INCLUDE "PLSR210.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
static objCENFUNLGP := CENFUNLGP():New() 
static lautoSt := .F.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PLSR210 � Autor � Marco Paulo            � Data � 03.09.02 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Etiquetas de Credenciados.                                 ���
�������������������������������������������������������������������������Ĵ��
���            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Altera��o                     ���
�������������������������������������������������������������������������Ĵ��
���Brunoro     �12/11/02�      �Equalizacao                               ���
���Brunoro     �20/12/02�      �                                          ���
���Brunoro     �03/04/03�      �Acerto Local de atendimento               ���
���Brunoro     �09/04/03�      �Inclusao do campo COMENTARIO no L. atend. ���
���Brunoro     �22/05/03�      �Inclusao do parametro Numero de copias    ���
���Brunoro     �01/10/03�      �Acerto de relacionamento do BB8 com o BAX ���
���Sandro H.   �23/06/06�97403 �Listar etiqueta dos Locais de Atendimento ���
���            �        �      �cujo campo "Correspondencia" esteja igual ���
���            �        �      �a "1-Sim". Nao listar etiqueta dos Locais ���
���            �        �      �de Atendimento que estiverem bloqueados.  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
//��������������������������������������������������������������������������Ŀ
//� Define nome da funcao                                                    �
//����������������������������������������������������������������������������
Function PLSR210(lauto)
//��������������������������������������������������������������������������Ŀ
//� Define variaveis padroes para todos os relatorios...                     �
//����������������������������������������������������������������������������
PRIVATE cNomeProg   := "PLSR210"
PRIVATE nCaracter   := 220
PRIVATE nQtdLin     := 58       // Qtd de Linhas Por Pagina
PRIVATE nLimite     := 220
PRIVATE cTamanho    := "G"
PRIVATE cTitulo     := STR0001 //"IMPRESSAO DE ETIQUETAS DE CREDENCIADOS"
PRIVATE cDesc1      := ""
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BAU"
PRIVATE cPerg       := "PLS210"
PRIVATE nRel        := "PLSR210"
PRIVATE nlin        := 00
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {STR0002,STR0003}  //"Codigo"###"Nome"
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 }
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := ""
PRIVATE cCabec2     := ""
PRIVATE nColuna     := 00
PRIVATE nOrdSel     := ""
//��������������������������������������������������������������������������Ŀ
//� Dados do parametro SX1...                                                �
//����������������������������������������������������������������������������
PRIVATE cOpeDe
PRIVATE cOpeAte
PRIVATE cGrupo
PRIVATE cEspec
PRIVATE cMesNas
PRIVATE cCreden
PRIVATE cCodMun
PRIVATE cCepDe
PRIVATE cCepAte
PRIVATE nImpCod
PRIVATE nBloq
PRIVATE nCopias

default lauto := .F.

lautost := lAuto

//-- LGPD ----------
if !lAuto .AND. !objCENFUNLGP:getPermPessoais()
	objCENFUNLGP:msgNoPermissions()
	Return
Endif
//------------------

//��������������������������������������������������������������������������Ŀ
//� Testa ambiente do relatorio somente top...                               �
//����������������������������������������������������������������������������
If !lAuto .AND. ! PLSRelTop()
	Return
Endif
//��������������������������������������������������������������������������Ŀ
//� Chama SetPrint                                                           �
//����������������������������������������������������������������������������
if !lAuto
	nRel  := SetPrint(cAlias,nRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
endif
//��������������������������������������������������������������������������Ŀ
//� Verifica se foi cancelada a operacao (padrao)                            �
//����������������������������������������������������������������������������
If !lAuto .AND. nLastKey == 27
	Return
Endif
//��������������������������������������������������������������������������Ŀ
//� Acessa parametros do relatorio...                                        �
//����������������������������������������������������������������������������
Pergunte(cPerg,.F.)
cOpeDe        := mv_par01
cOpeAte       := mv_par02
cGrupo        := mv_par03

If mv_par04 == 0
	intNumColunas := 3
Else
	intNumColunas := mv_par04
Endif

cEspec        := mv_par05
cMesNas       := mv_par06
cCreden       := Alltrim(mv_par07)
cCodMun       := mv_par08
cCepDe        := mv_par09
cCepAte       := mv_par10
nImpCod       := mv_par11
nBloq         := mv_par12
nCopias       := mv_par13
//��������������������������������������������������������������������������Ŀ
//� Configura impressora (padrao)                                            �
//����������������������������������������������������������������������������
if !lAuto
	SetDefault(aReturn,cAlias)
endif
//��������������������������������������������������������������������������Ŀ
//� Emite relat�rio                                                          �
//����������������������������������������������������������������������������
if !lAuto
	MsAguarde({|| R210Imp() }, cTitulo, "", .T.)
else
	R210Imp()
endif
//��������������������������������������������������������������������Ŀ
//� Fecha arquivo...                                                   �
//����������������������������������������������������������������������
ETQ->(DbCloseArea())
//���������������������������������������������������������������������Ŀ
//� SETA A IMPRESSORA para impressao normal                             �
//�����������������������������������������������������������������������
@nLin,00 PSAY Chr(18)                   // DesCompressao de Impressao
//��������������������������������������������������������������������������Ŀ
//� Libera impressao                                                         �
//����������������������������������������������������������������������������
If  !lAuto .AND. aReturn[5] == 1
	Set Printer To
	Ourspool(nRel)
End
//��������������������������������������������������������������������������Ŀ
//� Fim do relatorio                                                         �
//����������������������������������������������������������������������������
Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R210Imp  � Autor � Guilherme Brunoro     � Data � 20.12.02 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Imprime detalhe do relatorio...                            ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/
Static Function R210Imp()
Local nAux
//��������������������������������������������������������������������������Ŀ
//� Define variaveis...                                                      �
//����������������������������������������������������������������������������
PRIVATE cSQL
PRIVATE nOrdSel  := aReturn[8]
PRIVATE I        := 1
PRIVATE J        := 0
PRIVATE Lin      := Array(5,intNumColunas)
PRIVATE cCodCred := ""
PRIVATE cCodigo  := ""
//��������������������������������������������������������������������������Ŀ
//� Exibe mensagem...                                                        �
//����������������������������������������������������������������������������
if !lAutoSt
	MsProcTxt(PLSTR0001)
endif
//��������������������������������������������������������������������������Ŀ
//� Faz filtro no arquivo...                                                 �
//����������������������������������������������������������������������������
cSQL := "SELECT BAU_TIPPRE,BAU_CODIGO,BAU_NOME,BAU_END,BAU_BAIRRO,BAU_MUN,BAU_EST,BAU_CEP,BAX_CODESP, BB8_CRPLOC, " //BAU_CORRES,
cSQL += " BB8_END,BB8_BAIRRO,BB8_CODMUN,BB8_EST,BB8_CEP,BB8_CORRES,BB8_NR_END,BB8_COMEND,BB8_DATBLO"
cSQL += " FROM "+RetSQLName("BAX")+","+RetSQLName("BB8")+","+RetSQLName("BAW")+","+RetSQLName("BAU")+" "
cSQL += " WHERE BAU_FILIAL = '"+xFilial("BAU")+"'    "
cSQL += " AND   BB8_FILIAL = '"+xFilial("BB8")+"'    "
cSQL += " AND   BAX_FILIAL = '"+xFilial("BAX")+"'    "
cSQL += " AND   BAW_FILIAL = '"+xFilial("BAW")+"'    "
cSQL += " AND  "+RetSQLName("BAW")+".D_E_L_E_T_ = '' "
cSQL += " AND  "+RetSQLName("BAX")+".D_E_L_E_T_ = '' "
cSQL += " AND  "+RetSQLName("BB8")+".D_E_L_E_T_ = '' "
cSQL += " AND  "+RetSQLName("BAU")+".D_E_L_E_T_ = '' "
cSQL += " AND BAU_CODIGO = BB8_CODIGO "
cSQL += " AND BB8_CODIGO = BAX_CODIGO "
cSQL += " AND BB8_CODLOC = BAX_CODLOC "
cSQL += " AND BAU_CODIGO = BAW_CODIGO "
cSQL += " AND BAW_CODINT >= '"+cOpeDe+"'" + " AND BAW_CODINT <= '"+cOpeAte+"'"
cSQL += " AND BAU_CEP    >= '"+cCepDe+"'" + " AND BAU_CEP    <= '"+cCepAte+"'"

//���������������������������������������������������������������������Ŀ
//� BOPS 97403 - Nao listar etiqueta de Local de Atendimento bloqueado. �
//�����������������������������������������������������������������������
cSQL += " AND BB8_DATBLO = '        ' "

//��������������������������������������������������������������������Ŀ
//� Controla o municipio informado no paramentro...                    �
//����������������������������������������������������������������������
If ! Empty(cCodMun)
	cSQL += " AND ((BB8_CORRES = '1' AND BB8_CODMUN = '" + cCodMun + "') OR "
	cSQL += "      (BB8_CORRES = '0' AND BB8_CRPLOC <> ' ') OR "
	cSQL += "      (BB8_CORRES = '0' AND BB8_CRPLOC =  ' ' AND BAU_MUN = '" + cCodMun + "')) "
Endif

If ! Empty(cCreden)
	cSQL += " AND BAU_CODIGO IN ("+cCreden+") "
Endif

If ! Empty(cEspec)
	cSQL += " AND BAX_CODESP IN ("+Alltrim(cEspec)+") "
Endif

If ! Empty(cGrupo)
	cSQL += " AND BAU_TIPPRE = '"+cGrupo+"' "
Endif

If ! Empty(cMesNas)
	cSQL += " AND SUBSTRING(BAU_NASFUN,5,2) = '"+cMesNas+"'"
Endif

If nBloq == 2
	cSQL += " AND BAU_DATBLO = ' ' "
Endif
//��������������������������������������������������������������������������Ŀ
//� Se houver filtro executa parse para converter expressoes adv para SQL    �
//����������������������������������������������������������������������������
If ! Empty(aReturn[7])
	cSQL += " AND (" + PLSParSQL(aReturn[7])+" ) "
Endif
//��������������������������������������������������������������������������Ŀ
//� De acordo com a ordem....                                                �
//����������������������������������������������������������������������������
If      nOrdSel == 1
	cSQL += " ORDER BY BAU_CODIGO, BB8_CORRES"
ElseIf  nOrdSel == 2
	cSQL += " ORDER BY BAU_NOME, BB8_CORRES"
Endif

PLSQuery(cSQL,"ETQ")
//���������������������������������������������������������������������Ŀ
//� SETA A IMPRESSORA PARA A POSICAO zero e condensado                  �
//�����������������������������������������������������������������������
if !lAutoSt
	setprc(0,0)
endif
@nLin,nColuna PSAY Chr(15)                   // Compressao de Impressao

//��������������������������������������������������������������������������Ŀ
//� Processa relat�rio                                                       �
//����������������������������������������������������������������������������
For nAux := 1 TO nCopias
	ETQ->(DbGotop())
	if !lAutoSt
		MsAguarde({|| R210Proc() }, cTitulo, "", .T.)
	else
		R210Proc()
	endif
Next nAux

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R210Proc � Autor � Guilherme Brunoro     � Data � 20.12.02 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Imprime detalhe do relatorio...                            ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/
Static Function R210Proc()
Local i,j

While ! ETQ->(Eof())
	nColuna := 0
	I       := 1
	J       := 0
	//��������������������������������������������������������������������Ŀ
	//� Verifica se foi abortada a impressao...                            �
	//����������������������������������������������������������������������
	If !lAutoSt .AND. Interrupcao(lAbortPrint)
		nLin ++
		@ nLin, nColuna pSay PLSTR0002
		Exit
	Endif
	
	//��������������������������������������������������������������������Ŀ
	//� Exibe mensagem...                                                  �
	//����������������������������������������������������������������������
	if !lAutoSt
		MsProcTXT(STR0004+".. "+ETQ->BAU_CODIGO+"...") //"Imprimindo"
	endif
	//���������������������������������������������������������������������Ŀ
	//� Monta array com etiquetas...      								    �
	//�����������������������������������������������������������������������
	Lin := Array(5,intNumColunas)
	
	While I <= intNumColunas  .And. ! ETQ->(Eof())
		//��������������������������������������������������������������������Ŀ
		//� Verifica se ja atingiu o limite da pagina...                       �
		//����������������������������������������������������������������������
		If nLin > 60
			Chr(12)
			nLin := 1
		EndIf
		//��������������������������������������������������������������������Ŀ
		//� Verifica se ja imprimiu o credenciado...                           �
		//����������������������������������������������������������������������
		//��������������������������������������������������������������������Ŀ
		//� BOPS 97403 - Se ja listou a RDA pelo menos uma vez e o endereco    �
		//�              de correspondencia que devera ser listado eh o da     �
		//�              RDA e nao o do Local de Atendimento, despreza.        �
		//����������������������������������������������������������������������
		If ETQ->BAU_CODIGO == cCodCred .And. ETQ->BB8_CORRES == "0"
			ETQ->(DbSkip())
			Loop
		Endif
		
		//��������������������������������������������������������������������Ŀ
		//� Verifica qual endereco: do credenciado ou do local de atendmento.. �
		//����������������������������������������������������������������������
		If ETQ->BB8_CORRES == "1"
			If nImpCod == 1 //Imprime codigo
				cCodigo  := Substr(STR0002+": " + ETQ->BAU_CODIGO,1,42) //"CODIGO"
			Endif
			cNome    := Substr(ETQ->BAU_NOME,1,42)
			cEndere  := Substr(Alltrim(ETQ->BB8_END)+",",1,42)+Alltrim(ETQ->BB8_NR_END)+" "+Alltrim(ETQ->BB8_COMEND)
			cBairro  := AllTrim(ETQ->BB8_BAIRRO)
			cMunici  := Posicione("BID",1,xFilial("BID")+ETQ->BB8_CODMUN,"BID_DESCRI")
			cEstado  := Alltrim(ETQ->BB8_EST)
			cCep     := Substr(ETQ->BB8_CEP,1,5)+"-"+Substr(ETQ->BB8_CEP,6,3)
			
		Elseif ETQ->BB8_CORRES == "0" .and. !Empty(ETQ->BB8_CRPLOC)
			
			BB8->( dbSetorder(03) )
			If BB8->( dbSeek(xFilial("BB8")+ETQ->BAU_CODIGO+ETQ->BB8_CODINT+ETQ->BB8_CRPLOC) )
				
				//��������������������������������������������������������������������Ŀ
				//� Contrala o municipio informado no paramentro...                    �
				//����������������������������������������������������������������������
				If !Empty(cCodMun)
					If BB8->BB8_CODMUN <> cCodMun
						ETQ->( dbSkip() )
						Loop
					Endif
				Endif
				
				If nImpCod == 1 //Imprime codigo
					cCodigo  := Substr(STR0002+": " + ETQ->BAU_CODIGO,1,42) //"CODIGO"
				Endif
				cNome    := Substr(ETQ->BAU_NOME,1,42)
				cEndere  := Substr(Alltrim(BB8->BB8_END)+",",1,42)+Alltrim(BB8->BB8_NR_END)+" "+Alltrim(BB8->BB8_COMEND)
				cBairro  := AllTrim(BB8->BB8_BAIRRO)
				cMunici  := Posicione("BID",1,xFilial("BID")+BB8->BB8_CODMUN,"BID_DESCRI")
				cEstado  := Alltrim(BB8->BB8_EST)
				cCep     := Substr(BB8->BB8_CEP,1,5)+"-"+Substr(BB8->BB8_CEP,6,3)
			Else
				//��������������������������������������������������������������������Ŀ
				//� Contrala o municipio informado no paramentro...                    �
				//����������������������������������������������������������������������
				If !Empty(cCodMun)
					If ETQ->BAU_MUN <> cCodMun
						ETQ->( dbSkip() )
						Loop
					Endif
				Endif
				If nImpCod == 1 //Imprime codigo
					cCodigo  := Substr(STR0002+": " + ETQ->BAU_CODIGO,1,42) //"CODIGO"
				Endif
				cNome    := Substr(ETQ->BAU_NOME,1,42)
				cEndere  := Substr(Alltrim(ETQ->BAU_END),1,42)
				cBairro  := AllTrim(ETQ->BAU_BAIRRO)
				cMunici  := Posicione("BID",1,xFilial("BID")+ETQ->BAU_MUN,"BID_DESCRI")
				cEstado  := Alltrim(ETQ->BAU_EST)
				cCep     := Substr(ETQ->BAU_CEP,1,5)+"-"+Substr(ETQ->BAU_CEP,6,3)
			Endif
		Else
			If nImpCod == 1 //Imprime codigo
				cCodigo  := Substr(STR0002+": " + ETQ->BAU_CODIGO,1,42) //"CODIGO"
			Endif
			cNome    := Substr(ETQ->BAU_NOME,1,42)
			cEndere  := Substr(Alltrim(ETQ->BAU_END),1,42)
			cBairro  := AllTrim(ETQ->BAU_BAIRRO)
			cMunici  := Posicione("BID",1,xFilial("BID")+ETQ->BAU_MUN,"BID_DESCRI")
			cEstado  := Alltrim(ETQ->BAU_EST)
			cCep     := Substr(ETQ->BAU_CEP,1,5)+"-"+Substr(ETQ->BAU_CEP,6,3)
			
		Endif
		//������������������������������������������������������������������������������������Ŀ
		//� Monto array com dados da etiqueta ...                                              �
		//��������������������������������������������������������������������������������������
		Lin[1,I]:= cCodigo
		Lin[2,I]:= cNome
		Lin[3,I]:= cEndere + " "
		Lin[4,I]:= cBairro+" - "+cMunici
		Lin[5,I]:= cEstado+"  "+STR0005+":" +cCep //"CEP"
		
		cCodCred := ETQ->BAU_CODIGO
		ETQ->(DbSkip())
		
		I += 1
		If ETQ->(Eof())
			I = 3 + 1
		Endif
	Enddo
	I := 0
	For J := 1 to 5
		For I := 1 TO intNumColunas
			nColuna := (I-1) * 73
			@nLin,nColuna PSAY Lin[J,I]
		Next I
		nLin += 1
	Next J
	nLin += 1
Enddo

//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina...                                                         �
//����������������������������������������������������������������������������
Return
