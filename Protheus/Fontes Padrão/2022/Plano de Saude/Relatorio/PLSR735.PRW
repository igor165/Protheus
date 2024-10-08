#include "PROTHEUS.CH"
#include "PLSR735.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PLSR735  � Autor � Natie Sugahara        � Data � 18/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Autorizacao Especial para procedimento                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PLSR735                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���              �        �      �                                        ��� 
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSR735()

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL aArea		:= GetArea()

PRIVATE wnRel
PRIVATE cNomeProg   := "PLSR730"
PRIVATE Titulo		:= oEmToAnsi(STR0001)
PRIVATE cDesc1      := oEmToAnsi(STR0001)
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cString     := "BEA"
PRIVATE cPerg       := "PLR730"
PRIVATE Li         	:= 0
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrd		:= {}
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := ""
PRIVATE cCabec2     := ""
PRIVATE aReturn 	:= { OemtoAnsi(STR0004), 1,OemtoAnsi(STR0005), 2, 2, 1, "", 1 }  	//"Zebrado"###"Administracao"
PRIVATE aLinha		:= { }
PRIVATE nomeprog	:="PLSR735",nLastKey := 0
PRIVATE Tamanho 	:= "P" 
PRIVATE nLimite     := 080
PRIVATE nSvRecno	:= BEA->( Recno() )												//Salva posicao do BEA para Restaurar apos SetPrint()

If ! (BEA->BEA_STATUS $ "1,4")
   Help("",1,"PLSR735")
   Return
Endif                         

If BEA->BEA_STATUS == "4"
   BEA->(RecLock("BEA",.F.))
   BEA->BEA_STATUS := "1"
   BEA->(MsUnLock())
Endif

wnrel:="PLSR735"    																	//--Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,,@Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.F.,tamanho)

/*��������������������������������������������������������������������������Ŀ
  | Verifica se foi cancelada a operacao                                     �
  ����������������������������������������������������������������������������*/
If nLastKey  == 27
	Return
Endif
/*��������������������������������������������������������������������������Ŀ
  � Configura impressora                                                     �
  ����������������������������������������������������������������������������*/
SetDefault(aReturn,cString)
If nLastKey = 27
	Return
Endif 

RptStatus({|lEnd| R735Imp(@lEnd,wnRel,cString)},Titulo)

/*
��������������������������������������������������������������Ŀ
�Restaura Area e Ordem de Entrada                              �
����������������������������������������������������������������*/
RestArea( aArea)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R735IMP  � Autor � Natie Sugahara        � Data � 18/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PLSR735                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function R735Imp(lEnd,wnRel,cString)

Local cDet 			:= ""
Local cChave		:= ""
Local cPict			:= "@E 9,999.9999"
Local nCount		:= 0 
Local nLinDetMax	:= 05 									//-- Numero maximo de linhas detalhe

Private nLin		:= 02

DbSelectArea("BEA")
//-- Posiciona o ponteiro
BEA->( dbGoto( nSvRecno ) )	

/*��������������������������������������������������������������Ŀ
  �Impressao do Cabecalho                                        �
  ����������������������������������������������������������������*/
	fImpCabec()
/*��������������������������������������������������������������Ŀ
  �Dados do Usuario                                              |
  ����������������������������������������������������������������*/
	fDadosUsua()
/*��������������������������������������������������������������Ŀ
  �Cabecalho do Detalhe                                          |
  ����������������������������������������������������������������*/
	fDetCabec()

/*      10        20        30        40        50        60        70       80 
1234567890123456789012345678901234567890123456789012345678901234567890123456789 
     ----------------------------------------------------------------------  
     AMB         Descricao                              Qtde           CH
     ----------------------------------------------------------------------
     !!.!!.!!!-! xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx     99   9,999.9999
*/

BE2->(DbSetOrder(1))
cChave	:= xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT )
If BE2->(DbSeek( cChave ) )
	While !BE2->(EOF()) .and. cChave==BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)
	
		If ncount =  nLinDetMax
				fImpRoda()
			/*��������������������������������������������������������������Ŀ
			  �Impressao do Cabecalho                                        �
			  ����������������������������������������������������������������*/
				fImpCabec()
			/*��������������������������������������������������������������Ŀ
			  �Dados do Usuario                                              |
			  ����������������������������������������������������������������*/
				fDadosUsua()
			/*��������������������������������������������������������������Ŀ
			  �Cabecalho do Detalhe                                          |
			  ����������������������������������������������������������������*/
				fDetCabec()
		Endif

		//-- Linha de Detalhe
		@ nLIn, 005 psay TransForm(BE2->BE2_CODPRO,"@R !!.!!.!!!-!") 	//-- AMB
		@ nLIn, 017 psay Left(BE2->BE2_DESPRO,37)                      //-- Descricao
		@ nLIn, 058 psay Transform(BE2->BE2_QTDPRO,"@R 99")            //-- Qtde
		BC6->(dbSetOrder(1))
		If BC6->(dbSeek( xFilial("BC6") + BE2->(BE2_OPEMOV+BE2_CODRDA+ "01"+ BE2_CODPAD + BE2_CODPRO)   ) )
			cDet := Transform(BC6->BC6_USPCO,cPict )       					//-- CH
		Else
			cDet := Transform( 0            ,cPict) 
		Endif
		@ nLin ,064 psay cDet
		nLin ++
		nCount	++
		BE2->( DbSkip() )
	Enddo
EndIf
nLin ++
@ nLin ,005 psay  "---------------------------------------------------------------------"
nLin ++
fImpRoda()
fImpRecibo()
fImpRecibo() 

/*��������������������������������������������������������������������������Ŀ
  � Libera impressao                                                         �
  ����������������������������������������������������������������������������*/
m_pag := 0

If  aReturn[5] == 1
	Set Printer To
	Ourspool(wnRel)
EndIf
/*��������������������������������������������������������������������������Ŀ
  � Fim do Relat�rio                                                         �
  ����������������������������������������������������������������������������*/

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �fImpCabec   �Autor  �Microsiga           � Data �  18/09/03   ���
���������������������������������������������������������������������������͹��
���Desc.     �Cabecalho da Guia                                             ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � Generico                                                     ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function fImpCabec()
Local cFileLogo		:= ""
Local cPrazoLib		:= StrZero(GetMv("MV_PLPRZLB"),02)
Local cDet			:= ""          

/*��������������������������������������������������������������Ŀ
  �Reinicializa nLIn                     					     �
  ����������������������������������������������������������������*/
nLin		:= 02

/*��������������������������������������������������������������Ŀ
  �Setar Impressora Tamanho Normal       					     �
  ����������������������������������������������������������������*/
aDriver		:= ReadDriver()                  
If aReturn[4] == 1  // Comprimido
    @ 0,0 PSAY &(if(Tamanho=="P",aDriver[2],if(Tamanho=="G",aDriver[5],aDriver[3])))
Else                // Normal
    @ 0,0 PSAY &(if(Tamanho=="P",aDriver[2],if(Tamanho=="G",aDriver[6],aDriver[4])))
Endif

@ nLin , 0 PSAY &(aDriver[4])

/*��������������������������������������������������������������Ŀ
  �Impressao dos Dados Da Operadora 						     �
  ����������������������������������������������������������������*/
fImpNomOpe()

/*��������������������������������������������������������������Ŀ
  �AUTORIZACAO DE GUIA                                           �
  ����������������������������������������������������������������*/
nLin ++
cDet := OemToAnsi(STR0001)+ OemToAnsi(STR0006) + space(1) 
cDet += BEA->(BEA_OPEMOV+"."+BEA_ANOAUT+"."+BEA_MESAUT+"-"+BEA_NUMAUT) 
@ nLin , 001 psay cDet 
nLin ++ 

/*��������������������������������������������������������������Ŀ
  �Prestador de Servico                                          �
  ����������������������������������������������������������������*/
BB8->(DbSetOrder(1))
BB8->(DbSeek(xFilial("BB8")  +BEA->(BEA_CODRDA+BEA_OPERDA+ BEA_CODLOC+BEA_LOCAL )))
@ nLin , 001 psay OemToAnsi(STR0013)+ space(1) +BB8->(BB8_CODLOC       + "." + BB8_LOCAL + space(1) + Alltrim(BB8_DESLOC) ) //-- "Prestador : "
nLin ++
@ nLin , 014 psay BB8->(Alltrim(BB8_END) +","  + BB8_NR_END+"-"+Alltrim(BB8_COMEND) ) 
nLin ++ 
@ nLin , 014 psay alltrim(BB8->BB8_BAIRRO)+ space(1) + fDesc("BID",BB8->BB8_CODMUN,"BID_DESCRI") + "-" + BB8->BB8_EST  + space(1) + "Fone: "+ BB8->BB8_TEL
nLin  ++

Return(nil)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �fDadosUsua  �Autor  �Microsiga           � Data �  18/09/03   ���
���������������������������������������������������������������������������͹��
���Desc.     �Informacoes do Usuario                                        ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � Generico                                                     ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/ 
Static Function fDadosUsua()
Local cDet := "" 

/*��������������������������������������������������������������Ŀ
  �Usuario  / codigo                                             �
  ����������������������������������������������������������������*/
nLin ++
cDet 	:= OemToAnsi(STR0007) + space(1) + BEA->(substr(BEA_OPEMOV,1,1)+substr(BEA_OPEMOV,2,3)+"."+BEA_CODEMP+"."+BEA_MATRIC+"."+BEA_TIPREG+"-"+BEA_DIGITO)
cDet	+= space(2) + BEA->BEA_NOMUSR + space(1)
@ nLIn , 001 psay cDet 
nLin ++

/*��������������������������������������������������������������Ŀ
  �Empresa                                                       �
  ����������������������������������������������������������������*/
BG9->(DbSetOrder(1))
BG9->(DbSeek( xFilial("BG9") + BA1->(BA1_CODINT+BA1_CODEMP) )  )
cDet := OemToAnsi(STR0008)   + space(1) + BA1->( BA1_CODINT+BA1_CODEMP )
cDet += If( Empty( BA1->(BA1_CONEMP+BA1_SUBCON) ),"" , Transform(BA1->(BA1_CONEMP+BA1_SUBCON) , "@R ############-#########" )   ) + space(1) 
cDet += BG9->BG9_DESCRI 
@ nLin ,001 psay cDet
nLin ++

/*��������������������������������������������������������������Ŀ
  �Plano                                                         �
  ����������������������������������������������������������������*/
BI3->(DbSetOrder(1))
BI3->(DbSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
cDet := OemToAnsi(STR0009) + space(1) + BI3->(BI3_CODIGO + "-"+BI3_DESCRI ) 
@ nLin ,001 psay cDet
nLin += 1


Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �fDDetCabec  �Autor  �Microsiga           � Data �  18/09/03   ���
���������������������������������������������������������������������������͹��
���Desc.     �Imprime cabecalho da Guia                                     ���
���          � (Linha de Detalhe)                                           ���
���������������������������������������������������������������������������͹��
���Uso       � Generico                                                     ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function  fDetCabec()
//Local cDet := ""
/* 

123456789012345678901234567890123456789012345678901234567890123456789
---------------------------------------------------------------------
AMB         Descricao                            Qtde              CH
---------------------------------------------------------------------
!!.!!.!!!-! xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx      9999      999,999.99

---------------------------------------------------------------------
			Total                                9999    9,999,999.99
*/

/*��������������������������������������������������������������Ŀ
  �Impressao do Cabecalho da Linha de Detalhe                    �
  �Procedimentos autorizados                                     �
  ����������������������������������������������������������������*/             	
@ nLin, 005 psay  oemToAnsi(STR0011) 									//-- Procedimentos autorizados
/*��������������������������������������������������������������Ŀ
  �CID PRINCIPAL                                                 �
  ����������������������������������������������������������������*/             	
@ nLin, 050 psay OemToAnsi(STR0012)  + space(1) + BEA->BEA_CID 
nLin  ++
@ nLin ,005 psay  "---------------------------------------------------------------------"
nLin  ++
@ nLin, 005 psay  oemToAnsi(STR0015)
nLin  ++
@ nLin ,005 psay  "---------------------------------------------------------------------"
nLin  ++
Return


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �fImpRoda    �Autor  �Microsiga           � Data �  18/09/03   ���
���������������������������������������������������������������������������͹��
���Desc.     �Imprime rodape                                                ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � Generico                                                     ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/ 
Static Function  fImpRoda(li)
//Local cDet := ""

/*��������������������������������������������������������������Ŀ
  �Medico Solicitante                                            �
  ����������������������������������������������������������������*/
//BB0->( DbSetOrder(4) )
//BB0->(DbSeek(xFilial("BB0")+BEA->(BEA_ESTSOL+BEA_REGSOL+BEA_SIGLA))) 
@ nLin ,001  psay OemToAnsi(STR0010) + space(1) +BEA->BEA_ESTSOL+"-"+BEA->BEA_REGSOL+"-"+BEA->BEA_SIGLA+ SPACE(1)+ alltrim( BEA->BEA_NOMSOL )   	//-- Nome  + CRM
nLin += 3

/*��������������������������������������������������������������Ŀ
  �Assinatura do Beneficiario                                    �
  ����������������������������������������������������������������*/
@ nLin, 001 psay repl("-",30)
nLin ++
@ nLin, 001 psay OemToAnsi(STR0014)  								//-- Assinatura do Beneficiario
nLin ++

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fImpRecibo�Autor  �Natie Sugahara      � Data �  18/09/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �Impressao do Recibo                                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fImpRecibo()
Local cDet 			:= ""
Local cNumRecibo 	:= BEA->(BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
Local nValor  	 	:= BEA->BEA_VALOR
//Local cRet1			:= ""
//Local cRet2			:= ""

/*                                                                              
    10        20        30        40        50        60        70        80                              
5678901234567890123456789012345678901234567890123456789012345678901234567890




___________________________________________________________________________
Recibo No 999999999                                    Valor : R$ 999,999.99


     Recebemos do usuario abaixo denominado,  a importancia de R$ 999,999.99
(NOVECENTOS E NOVENTA E NOVE MIL E NOVENTA E NOVE CENTAVOS ***************),
referente ao pagamento de servicos a  serem  prestados  por  Cooperados e/ou 
Credenciados da EMPRESA   ..................................................

Codigo da Familia : 99999999999999-99 xxxxxxxxxxxxxxxxxxxxxxxxxxxxx

                                    
                             xxxxxxxxxxxxxxxxxxxx,  99 de xxxxxxxxxx de 9999
						                   

                             Nome Empresa
    	 				     Setor Financeiro 
____________________________________________________________________________

----------------------------------------------------------------------------  
*/
@ nLin, 001 psay repl("-",80)
nLin ++

/*��������������������������������������������������������������Ŀ
  �Impressao dos Dados Da Operadora 						     �
  ����������������������������������������������������������������*/
fImpNomOpe()

/*��������������������������������������������������������������Ŀ
  �Detalhe do Recibo                         				     �
  ����������������������������������������������������������������*/
nLIn ++
@ nLin , 001 psay oEmToAnsi(STR0016) + cNumRecibo
@ nLin , 050 psay oEmToAnsi(STR0017) + Transform(nValor    , "@E 999,999.99") 
nLin += 2
cDet := oEmtoAnsi(STR0018)+  space(1) 
cDet += Transform(nValor, "@E 999,999.99" ) 
@ nLin, 001 psay  cDet
nLin ++
@ nLin, 001 psay "("+Extenso(nValor ,.F.,1) + REPLICATE("*", 077 - LEN(EXTENSO(nValor,,,) ) )+ "),"
nLin ++
@ nLin, 001 psay oEmToAnsi(STR0019)
nLin ++
@ nLin, 001 psay oemToansi(STR0020) + left(BG9->BG9_DESCRI, 50 )
nLin ++
cDet := oemToAnsi(STR0007) + space(1) + BEA->(substr(BEA_OPEMOV,1,1)+substr(BEA_OPEMOV,2,3)+"."+BEA_CODEMP+"."+BEA_MATRIC+"."+BEA_TIPREG+"-"+BEA_DIGITO) + space(1)
cDet += BEA->BEA_NOMUSR
@ nLin, 001 psay cDet
nLin += 2
@ nlin, 001 psay Alltrim(BID->BID_DESCRI) + ", "+SUBSTR(DTOC(dDataBase),1,2)+ " de " + MesExtenso(MONTH(dDataBase)) + " de " + STR(YEAR(dDataBase),4)
@ nLin, 040 psay left(BA0->BA0_NOMINT,40)
nLin ++
@ nLin, 040 psay oEmToansi(STR0021) 
nLin ++ 
Return



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fImpNomOpe�Autor  �RH - Natie          � Data �  18/09/02   ���
�������������������������������������������������������������������������͹��
���Desc.     � Impressao dos Dados da Operadora                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function fImpNomOpe()

/*��������������������������������������������������������������Ŀ
  �Nome da Operadora 										     �
  ����������������������������������������������������������������*/

BA0->(DbSetOrder(1))
BA0->(DbSeek(xFilial("BEA")+ BEA->(BEA_OPEUSR) ) ) 
@ nLin, 001 psay  BA0->BA0_NOMINT
nLin  ++ 
/*��������������������������������������������������������������Ŀ
  �Endereco                										 �
  ����������������������������������������������������������������*/
BID->(DbSetOrder(1)) 
BID->(DbSeek( xFilial("BID")+BA0->(BA0_CODMUN ) )  )
@ nLin, 001 psay alltrim(BA0->BA0_END)   + space(02) + alltrim(BA0->BA0_BAIRRO)
nLin ++
@ nLIn, 001 psay Alltrim(BID->BID_DESCRI) + "-"+ BA0->BA0_EST + space(5) +oEmToAnsi(STR0022)  + BA0->BA0_CEP + space(05) +  "CGC: " +Transform(BA0->BA0_CGC,  "@R ##.###.###/####-##" )
nLin  ++


Return( Nil )