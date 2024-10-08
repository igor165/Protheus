
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSR816.CH"
#IFDEF TOP
	#INCLUDE "TOPCONN.CH"
#ENDIF

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR816 � Autor � Natie Sugahara         � Data � 14/07/03 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Consultas Efetuadas Por Empresa                            ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR816()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial                               ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
�������������������������������������������������������������������������Ĵ���
���          |      |             |                                       ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/                                
Function PLSR816(lAuto)
/*��������������������������������������������������������������������������Ŀ
  � Define variaveis padroes para todos os relatorios...                     �
  ����������������������������������������������������������������������������*/
PRIVATE wnRel         
PRIVATE cNomeProg   := "PLSR816"
PRIVATE nLimite     := 132
PRIVATE nTamanho    := "M"
PRIVATE Titulo		:= oEmToAnsi(STR0001)				//- Consultas Efetuadas por Empresa
PRIVATE cDesc1      := oEmToAnsi(STR0001)
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BBD"
PRIVATE cPerg       := "PLR816"
PRIVATE Li         	:= 0
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aReturn     := { oEmToAnsi(STR0002), 1,oEmToAnsi(STR0003) , 1, 1, 1, "",1 }
PRIVATE aOrd		:= { STR0004}													
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := ""
PRIVATE cCabec2     := ""

//��������������������������������������������������������������Ŀ
//� Variaveis Utilizadas na funcao IMPR                          �
//����������������������������������������������������������������
PRIVATE cCabec
PRIVATE Colunas		:= 132
PRIVATE AT_PRG  	:= "PLSR816"
PRIVATE wCabec0 	:= 1
PRIVATE wCabec1		:= space(3) + oEmToAnsi(STR0008)
PRIVATE wCabec2		:=""
PRIVATE wCabec3		:=""
PRIVATE wCabec4		:=""
PRIVATE wCabec5		:=""
PRIVATE wCabec6		:=""
PRIVATE wCabec7		:=""
PRIVATE wCabec8		:=""
PRIVATE wCabec9		:=""
PRIVATE CONTFL		:=1
PRIVATE cPathPict	:= ""

Pergunte(cPerg,.F.)
/*��������������������������������������������������������������Ŀ
  � Envia controle para a funcao SETPRINT                        �
  ����������������������������������������������������������������*/
wnrel:="Plsr816"					           //Nome Default do relatorio em Disco
wnrel:=SetPrint(cAlias,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho)

/*��������������������������������������������������������������������������Ŀ
  | Verifica se foi cancelada a operacao                                     �
  ����������������������������������������������������������������������������*/
If nLastKey  == 27
	Return
Endif
/*��������������������������������������������������������������������������Ŀ
  � Configura impressora                                                     �
  ����������������������������������������������������������������������������*/
If !lAuto
	SetDefault(aReturn,cAlias)
Endif	
If nLastKey = 27
	Return
Endif 

MsAguarde({|lEnd| R816Imp(@lEnd,wnRel,cAlias)},Titulo)

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R816Imp  � Autor � Natie Sugahara        � Data � 14/07/03 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Emite relatorio                                            ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function R816Imp()
Local   cSQL			:= ""
Local   cPict			:= "@E 999999"
Local   cDet     		:= ""
//Local   cData			:= ""
Local  	cEmpresa		:= ""
Local   cNomeEmp		:= ""
Local   cOperadora 		:= ""
Local 	nTotAtendidos	:= 0
Local	nTotTitular 	:= 0
Local 	nTotDepende		:= 0
Local	nTotTimeAtd		:= 0  
Local   cMvPLCDTGP      := GETMV("MV_PLCDTGP")
//Local   nOrdem  		:= aReturn[8]

/*��������������������������������������������������������������������������Ŀ
  � Acessa parametros do relatorio...                                        �
  � Variaveis utilizadas para parametros                                     �
  ����������������������������������������������������������������������������*/
cOpeDe     	:= mv_par01 				//-- Operadora De
cOpeAte    	:= mv_par02 				//-- Operadora ATe
cEmpreDe	:= mv_par03					//-- Empresa De
cEmpreAte	:= mv_par04					//-- Empresa Ate
dDataDe		:= mv_par05  				//-- Periodo De
dDataAte	:= mv_Par06					//-- Periodo Ate
nTimeAtd	:= mv_par07					//-- Relaciona Atdt Acima de

/*��������������������������������������������������������������������������Ŀ
  � Faz filtro no arquivo...                                                 �
  ����������������������������������������������������������������������������*/
#IFDEF TOP
	cSQL := "SELECT * FROM "+BBD->(RetSQLName("BBD"))+" WHERE "
	cSQL += "BBD_FILIAL = '"+xFilial("BBD")+"' "
	cSQL += "AND D_E_L_E_T_ = ' '  AND "
    cSQL += "BBD_STATUS = '4' AND "
	cSQL += "BBD_CODINT >= '" + cOpeDe          +"' AND BBD_CODINT <= '"+ cOpeAte       + "' AND "
	cSQL += "BBD_CODEMP >= '" + cEmpreDe        +"' AND BBD_CODEMP <= '"+ cEmpreAte     + "' AND "
	cSQL += "BBD_DATA   >= '" + DTOS(dDataDe)   +"' AND BBD_DATA   <= '"+ DTOS(dDataAte)+"' "
	
	/*��������������������������������������������������������������������������Ŀ
	  � Se houver filtro executa parse para converter expressoes adv para SQL    �
	  ����������������������������������������������������������������������������*/
	If ! Empty(aReturn[7])
		cSQL += " and " + PLSParSQL(aReturn[7])
	Endif 
	/*��������������������������������������������������������������������������Ŀ
	  � Define order by de acordo com a ordem...                                 �
      ���������������������������������������������������������������������������� */
	cSQL += " ORDER BY BBD_CODINT + BBD_CODEMP +  BBD_CODPAC + BBD_DATA "
	cSQL := PLSAvaSQL(cSQL)
	TCQUERY cSQL NEW ALIAS "BBDTrb"
#ENDIF

/*       10        20        30        40        50        60        70        80        90       100       110       120
0123456789012345678901234597890123459789012345978901234597890123459789012345978901234597890123459789012345978901234597890
Codigo                 Paciente                             Data Medico                      Especialid  Chega Atend
9.999.9999.999999-99-9 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 99/99/9999 999999 xxxxxxxxxxxxxxxxxxxx xxxxxxxxxx  99:99 99:99      
*/

Li 		:= 0
BBDTrb->(dbgoTop())
While  !( BBDTrb->(Eof()) )
	/*��������������������������������������������������������������������Ŀ
	  � Verifica se foi abortada a impressao ...                           �
	  ����������������������������������������������������������������������*/
	If Interrupcao(lAbortPrint)
		Exit
	Endif
	cOperadora	:= BBDTrb->BBD_CODINT
	Impr( "Operadora : " +BBDTrb->BBD_CODINT + space(1)+ fDesc("BA0", BBDTrb->BBD_CODINT,"BA0_NOMINT" ) ,"C",,,03,.T.)		//-- Operadora
	Impr( "Periodo   : " + dtoc(dDataDe)   + " a " + dToc( dDataAte ),"C",,,03,.T.)
	Impr("","C")
	While  !( BBDTrb->(Eof()) )   .and. cOperadora ==BBDTrb->BBD_CODINT
		cOperadora	:= BBDTrb->BBD_CODINT
		cEmpresa	:= alltrim(BBDTrb->BBD_CODEMP )            
		cNomeEmp	:= fDesc("BG9", cOperadora + cEmpresa,  "BG9_DESCRI" )
		/*��������������������������������������������������������������������Ŀ
		  � Exibe mensagem...                                                  �
		  ����������������������������������������������������������������������*/
		MsProcTXT("Imprimindo " + cOperadora + "-" + cNomeEmp+  "..." )
		Impr("","C")
		cDet		:= OemToansi(STR0005)+ cEmpresa + SPACE(1) + cNomeEmp 
		Impr(cDet, "C",,,03,.T.)
		Impr("","C")
		While  !( BBDTrb->(Eof()) )   .and. cOperadora + cEmpresa == BBDTrb->(BBD_CODINT + alltrim(BBD_CODEMP) ) 
			cDet	:= Transform(BBDTrb->BBD_CODPAC,"@R #.###.####.######-##-#")+SPACE(1) + left(BBDTrb->BBD_NOME,30)+ SPACE(1)				//-- Paciente
			cDet	+= ConverteData(BBDTrb->BBD_DATA )  + SPACE(1) 																			//-- Data Atendimento
			cDet	+= BBDTrb->(BBD_CODIGO + SPACE(1) + substr(fDesc("BAU", BBD_CODIGO, "BAU_NOME")	,1 ,20 )   ) + SPACE(1) 				//-- Medico
			cDet	+= substr(fDesc("BAQ",BBDTrb->(BBD_CODINT  + BBD_CODESP) ,"BAQ_DESCRI"),1,10)  + SPACE(2)									//-- Especialidade
			cDet	+= BBDTrb->(BBD_HORCHE + SPACE(1) + BBD_HORENT )
			Impr(cDet, "C" ,,, 03,.T.,.T.)
			nTotAtendidos	++
			If fDesc( "BA1", LEFT(BBDTrb->BBD_CODPAC,14) ,  "BA1_TIPREG"	 ) = cMvPLCDTGP
				nTotTitular ++
			Else
				nTotDepende ++
			Endif					
			If fVerAtraso() > nTimeAtd							//-- Relaciona tempo de atendimento acima  nTimeAtd
				nTotTimeAtd ++
			Endif
			BBDTrb->(dbSkip())
		Enddo
		If ( Li + 6 ) >= 58 
			Impr("","P")
		Endif
		Impr("","C")
		Impr(oEmToAnsi(STR0009) +  transform( nTotAtendidos , cPict   ) ,"C",,,03,.T. )
		Impr(oEmToAnsi(STR0010) +  transform( nTotTitular   , cPict   ) ,"C",,,03,.T. )
		Impr(oEmToAnsi(STR0011) +  transform( nTotDepende   , cPict   ) ,"C",,,03,.T. )
		Impr(oEmToAnsi(STR0012) + Transform(nTimeAtd, "@E 99" ) + " Min...  : " +  transform( nTotTimeAtd   , cPict   ) ,"C",,,03,.T. )
		nTotAtendidos	:= 0
		nTotTitular 	:= 0
		nTotDepende		:= 0
		nTotTimeAtd		:= 0
		/*��������������������������������������������������������������������Ŀ
		  � Verifica o Total de Usuario Titulares e Dependentes Ativos         �
		  ����������������������������������������������������������������������*/
		fTotalEmp(cOperadora ,cEmpresa )
	EndDo
	Impr("","C") 
Enddo	
Impr("","F")

/*��������������������������������������������������������������������Ŀ
  � Fecha arquivo...                                                   �
  ����������������������������������������������������������������������*/
BBDTrb->(DbCloseArea())

/*��������������������������������������������������������������������������Ŀ
  � Libera impressao                                                         �
  ����������������������������������������������������������������������������*/
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
���Programa  �fTotalEmp   �Autor  �Microsiga           � Data �  07/14/03   ���
���������������������������������������������������������������������������͹��
���Desc.     � Totaliza Usuarios da Empresa                                 ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � AP                                                           ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function  fTotalEmp(cOperadora ,  cEmpresa) 
Local nTotTit	:= 0
Local nTotDep	:= 0
Local cSQL		:= ""
Local cPict		:= "@E 999999"
Local cMvPLCDTGP := GETMV("MV_PLCDTGP")

#IFDEF TOP
	cSQL := "SELECT * FROM "+BA1->(RetSQLName("BA1"))+" WHERE "
	cSQL += "BA1_FILIAL = '"+xFilial("BA1")+"' "
	cSQL += "AND D_E_L_E_T_ = ' '  AND "
	cSQL += "BA1_DATBLO <> '' AND "
	cSQL += "BA1_CODEMP = '" + cEmpresa   +"' AND "
	cSQL += "BA1_CODINT = '" + cOperadora +"' "
	/*��������������������������������������������������������������������������Ŀ
	  � Se houver filtro executa parse para converter expressoes adv para SQL    �
	  ����������������������������������������������������������������������������*/
	If !Empty(aReturn[7])
		cSQL += " and " + PLSParSQL(aReturn[7])
	Endif
	cSQL := PLSAvaSQL(cSQL)
	TCQUERY cSQL NEW ALIAS "BA1Trb"
#ENDIF
BA1Trb->( dbgotop() )
While  !( BA1Trb->( eof())  ) 

	If BA1Trb->(BA1_TIPREG) = cMvPLCDTGP
		nTotTit ++
	Else
		nTotDep ++
	Endif
	BA1Trb->( dbSkip() )
Enddo
/*��������������������������������������������������������������������Ŀ
  � Imprime totais de Beneficiarios da Empresa                         �
  ����������������������������������������������������������������������*/
Impr( oEmToAnsi(STR0013) + transform(nTotTit , cPict   ) ,"C",,,03,.T. )
Impr( oEmToAnsi(STR0014) + transform(nTotDep , cPict   ) ,"C",,,03,.T. )
Impr("","C") 

/*��������������������������������������������������������������������Ŀ
  � Fecha arquivo...                                                   �
  ����������������������������������������������������������������������*/
BA1Trb->(dbCloseArea() ) 
Return(NIL)

Static Function ConverteData(cData )

Return ( substr(cData,7,2) + "/" + substr( cData,5,2) + "/" + substr(cData,1,4) )

//-------------------------------------------------------------------
/*/{Protheus.doc} fVerAtraso
Verifica Atraso (em Min)  
@author Vinicius.Queiros
@version P12
@since   28/09/2020
/*/
//-------------------------------------------------------------------
Static Function  fVerAtraso()

LOCAL nMin1 := 0
LOCAL nMin2 := 0
LOCAL nMin  := 0
LOCAL cHor1	:= ""
LOCAL cHor2	:= ""

	cHor1 	:= BBDTrb->BBD_HORCHE
	cHor2	:= BBDTrb->BBD_HORENT
	nMin1	:= (Val(SubStr(cHor1,1,2))*60)+Val(SubStr(cHor1,4,2))
	nMin2 	:= (Val(SubStr(cHor2,1,2))*60)+Val(SubStr(cHor2,4,2))
	nMin	:= (nMin2 - nMin1)

Return(nMin)

