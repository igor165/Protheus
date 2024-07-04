#include "PMSR210.ch"
#include "protheus.ch"


//--------------------------RELEASE 4-------------------------------------------//


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �PMSR210R4 � Autor �Paulo Carnelossi       � Data �05/07/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao do Relatorio para release 4 utilizando obj tReport   ���
���          �Relatorio de alocacao de recursos                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   � Manutencao efetuada                        ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PMSR210()
Private oTarefa
Private OITEMTAREFA
Private cTarefa  	:= ""

If PMSBLKINT()
	Return Nil
EndIf

oReport := ReportDef()

If !Empty(oReport:uParam)
	Pergunte(oReport:uParam,.F.)
EndIf	

oReport:PrintDialog()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Paulo Carnelossi       � Data �04/07/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local oReport
Local oProjeto
//Local oItemTarefa
Local aOrdem := {}
Local cPerg  := "PMR210"

// chamado atrav�s da opcao do menu
dbSelectArea("AF8")
dbSetOrder(1)

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������

oReport := TReport():New("PMSR210",STR0003, cPerg, ;
			{|oReport| ReportPrint()},;
			STR0001+CRLF+STR0003+CRLF+STR0002 )

//STR0001 //"Este programa tem como objetivo imprimir relatorio "
//STR0002 //"de acordo com os parametros informados pelo usuario."
//STR0003 //"Lista para Cotacao por Projeto"
//STR0003 //"Lista para Cotacao por Projeto"

//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
//adiciona ordens do relatorio

oProjeto := TRSection():New(oReport, STR0010,{"AF8", "SA1","AFE"}, aOrdem /*{}*/, .F., .F.) //"Projeto"

//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�                                                                        �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
TRCell():New(oProjeto,	"AF8_PROJET"	,"AF8",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"AF8_DESCRI"	,"AF8",/*Titulo*/,/*Picture*/,50/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

TRPosition():New(oProjeto, "SA1", 1, {|| xFilial("SA1") + AF8->AF8_CLIENT})
TRPosition():New(oProjeto, "AFE", 1, {|| xFilial("AFE") + AF8->AF8_PROJET + AF8->AF8_REVISA})

oProjeto:SetLineStyle()

oTarefa := TRSection():New(oProjeto,STR0011,{"AF9"}, aOrdem /*{}*/, .F., .F.)  //"Tarefa"

//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�                                                                        �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
TRCell():New(oTarefa,	"AF9_TAREFA"	,"AF9",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oTarefa,	"AF9_DESCRI"	,"AF9",/*Titulo*/,/*Picture*/,50/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

TRPosition():New(oTarefa, "AF8", 1, {|| xFilial("AF8") + AF9->AF9_PROJET + AF9->AF9_REVISA})
TRPosition():New(oTarefa, "AFE", 1, {|| xFilial("AFE") + AF9->AF9_PROJET + AF9->AF9_REVISA})

oTarefa:SetLineStyle()

oItemTarefa := TRSection():New(oTarefa,STR0012,{"AFA", "AE8", "SB1"}, aOrdem /*{}*/, .F., .F.) //"Item"

TRCell():New(oItemTarefa,	"AFA_PRODUT"	,"AFA",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oItemTarefa,	"AFA_TIPPRO"	,"",STR0015/*Titulo*/,/*Picture*/,8/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oItemTarefa,	"AFA_DESCRI"	,"AFA",/*Titulo*/,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oItemTarefa,	"AFA_QUANT"		,"AFA",/*Titulo*/,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oItemTarefa,	"AFA_QUANT1"	,"",STR0013/*Titulo*/,"@E 9,999,999.99"/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oItemTarefa,	"AFA_ANOTAC"	,"",STR0014/*Titulo*/,/*Picture*/,50/*Tamanho*/,/*lPixel*/,{||Repl("_",50)})

TRPosition():New(oItemTarefa, "AE8", 1, {|| xFilial("AE8") + AFA->AFA_RECURS})
//TRPosition():New(oItemTarefa, "SB1", 1, {|| xFilial("SB1") + AFA->AFA_PRODUT})


oItemTarefa:SetHeaderPage()
Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor �Paulo Carnelossi      � Data �29/05/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �que faz a chamada desta funcao ReportPrint()                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �ExpO1: Objeto TReport                                       ���
���          �ExpC2: Alias da tabela de Planilha Orcamentaria (AK1)       ���
���          �ExpC3: Alias da tabela de Contas da Planilha (Ak3)          ���
���          �ExpC4: Alias da tabela de Revisoes da Planilha (AKE)        ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint(  )
Local oProjeto  	:= oReport:Section(1)
Local oTarefa		:= oReport:Section(1):Section(1)
Local oItemTarefa	:= oReport:Section(1):Section(1):Section(1)
Local aProdutos		:= {}
Local aDescri		:= {}
Local cAliasAF8 	:= GetNextAlias()
Local cCondicao 	:= ""
Local nX, nZ, nColAux
Local cObfNRecur 	:= IIF(FATPDIsObfuscate("AE8_DESCRI",,.T.),FATPDObfuscate("RESOURCE NAME","AE8_DESCRI",,.T.),"")      


dbSelectArea("AF8")
dbSetOrder(1)

dbSelectArea("AF9")
dbSetOrder(1)

dbSelectArea("AFA")
dbSetOrder(1)

oItemTarefa:Cell("AFA_PRODUT")	:SetBlock( {|| IIF( !Empty(AFA->AFA_PRODUT),AFA->AFA_PRODUT,AFA->AFA_RECURS) } )
oItemTarefa:Cell("AFA_TIPPRO")	:SetBlock( {|| "(" + IIF( !Empty(AFA->AFA_PRODUT), "P", "R" ) + ")" } )
oItemTarefa:Cell("AFA_DESCRI")	:SetBlock( {|| IIF( !Empty(AFA->AFA_PRODUT),SB1->B1_DESC, IIF(Empty(cObfNRecur),AE8->AE8_DESCRI,cObfNRecur) ) } )
oItemTarefa:Cell("AFA_QUANT")	:SetBlock( {|| AFA->AFA_QUANT } )
oItemTarefa:Cell("AFA_QUANT1")	:SetBlock( {|| (AFA->AFA_CUSTD*PmsAFAQuant(AFA->AFA_PROJET,AFA->AFA_REVISA,AFA->AFA_TAREFA,AFA->AFA_PRODUT,AF9->AF9_QUANT,AFA->AFA_QUANT,AF9->AF9_HDURAC)) / PmsAFAQuant(AFA->AFA_PROJET,AFA->AFA_REVISA,AFA->AFA_TAREFA,AFA->AFA_PRODUT,AF9->AF9_QUANT,AFA->AFA_QUANT,AF9->AF9_HDURAC) } )

// transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

// query do relatorio da secao 1
oProjeto:BeginQuery()	

BeginSql Alias cAliasAF8
SELECT AF8_PROJET, AF8_DESCRI, AF8_REVISA, R_E_C_N_O_ NumRec

FROM %table:AF8% AF8

WHERE AF8.AF8_FILIAL = %xFilial:AF8% AND 
	AF8.AF8_PROJET >=%Exp:mv_par01% AND
	AF8.AF8_PROJET <=%Exp:mv_par02% AND 
	AF8.%NotDel%

ORDER BY %Order:AF8%
		
EndSql 

//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�                                                                        �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�                                                                        �
//�ExpA1 : Array com os parametros do tipo Range                           �
//�                                                                        �
//��������������������������������������������������������������������������
oProjeto:EndQuery(/*Array com os parametros do tipo Range*/)

oReport:SetMeter((cAliasAF8)->(LastRec()))

dbSelectArea(cAliasAF8)
dbGoTop()

oProjeto:Init()

While (cAliasAF8)->(!Eof())

    //se for top posiciona no recno do AF8 
    AF8->(dbGoto((cAliasAF8)->NumRec))

	If oReport:Cancel()
		oReport:PrintText(STR0016)
		Exit
	EndIf

	aProdutos:= {}
	
	If mv_par10 == 1 .OR. (mv_par10 == 2 .AND. AFA->( dbSeek(xFilial("AFA")+AF8->AF8_PROJET+AF8->AF8_REVISA) ))
		
		If AFA->AFA_PRODUT >= mv_par04 .and. AFA->AFA_PRODUT <= mv_par05 
  		
	   	oProjeto:PrintLine()
    	oReport:SkipLine()

		// carrega os produtos do projeto/tarefa
		PMR210PR4(@aProdutos, @cAliasAF8, @oItemTarefa, @oTarefa, @oReport)
		oReport:ThinLine()
	EndIf 
EndIf
	
	oReport:IncMeter()	 

	dbSelectArea( cAliasAF8 )
	dbSkip()
	
EndDo

oProjeto:Finish()

(cAliasAF8)->(DbCloseArea())

Return

//Fun��o especifica para R4
Static Function PMR210PR4(aProdutos, cAliasAF8, oItemTarefa, oTarefa, oReport)
Local nPos	   := 0
Local nQuantAFA:= 0
Local cGrupAFA := ""
Local nRecAF8  := AF8->(recno())
Local cObfNRecur := IIF(FATPDIsObfuscate("AE8_DESCRI",,.T.),FATPDObfuscate("RESOURCE NAME","AE8_DESCRI",,.T.),"")      

dbSelectArea("AF9")
dbGoTop()
dbSeek(xFilial("AF9")+AF8->AF8_PROJET+AF8->AF8_REVISA) 
  		
While !AF9->(Eof()) .And. (xFilial("AF9")+AF8->AF8_PROJET+AF8->AF8_REVISA == AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA)
	If !PmrPertence(AF9->AF9_NIVEL,mv_par03)
		dbSelectArea("AF9")
		dbSkip()
		Loop
	Endif
	
	// pesquisa os produtos da tarefa
	dbSelectArea("AFA")
	dbSetOrder(1)  
				
	If dbSeek(xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
		While !AFA->(Eof()) .And. (xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA == AFA->AFA_FILIAL+AFA->AFA_PROJET+AFA->AFA_REVISA+AFA->AFA_TAREFA)
			If (mv_par08 == 2 .and. AFA->AFA_CUSTD == 0) .Or. (mv_par08 == 3 .and. AFA->AFA_CUSTD <> 0)
				dbSkip()
				Loop
			EndIf 
			
			cGrupAFA := Posicione("SB1",1,xFilial("SB1")+AFA->AFA_PRODUT,"B1_GRUPO")
			If AFA->AFA_PRODUT >= mv_par04 .and. AFA->AFA_PRODUT <= mv_par05 .and. cGrupAFA >= mv_par06 .and. cGrupAFA <= mv_par07
				
				nQuantAFA:= PmsAFAQuant(AFA->AFA_PROJET,AFA->AFA_REVISA,AFA->AFA_TAREFA,AFA->AFA_PRODUT,AF9->AF9_QUANT,AFA->AFA_QUANT,AF9->AF9_HDURAC)
				
				If Mv_Par09 == 2 //Imprime por tarefa
				
					If	Empty(AFA->AFA_PRODUT)
						dbSkip()
						Loop					
					Endif 
					
					If mv_par10 == 1 .Or. !Empty(AFA->AFA_PRODUT)
						If !Empty(AFA->AFA_PRODUT)
							nPos:= aScan(aProdutos,{|x| x[1]+x[2] == AFA->AFA_TAREFA+AFA->AFA_PRODUT	.And. x[5] =="P"})
						Else
							nPos:= aScan(aProdutos,{|x| x[1]+x[2] == AFA->AFA_TAREFA+AFA->AFA_RECURS	.And. x[5] =="R" })
						Endif							
						If (nPos > 0)
							aProdutos[nPos,3]+= nQuantAFA
							aProdutos[nPos,4]+= nQuantAFA * AFA->AFA_CUSTD
						Elseif AFA->AFA_PRODUT >= mv_par04 .and. AFA->AFA_PRODUT <= mv_par05
							If !Empty(AFA->AFA_PRODUT)
								aAdd(aProdutos,{AFA->AFA_TAREFA,AFA->AFA_PRODUT,nQuantAFA,AFA->AFA_CUSTD*nQuantAFA,"P",QbTexto(Posicione("SB1",1,xFilial("SB1")+AFA->AFA_PRODUT,"B1_DESC"), 030, " ")})
							Else
								aAdd(aProdutos,{AFA->AFA_TAREFA,AFA->AFA_RECURS,nQuantAFA,AFA->AFA_CUSTD*nQuantAFA,"R",QbTexto(IIF(Empty(cObfNRecur),Posicione("AE8",1,xFilial("AE8")+AFA->AFA_RECURS,"AE8_DESCRI"),cObfNRecur), 030, " ")})
						Endif  
						EndIf
					EndIf
				Else 
					If mv_par10 == 1 .Or. !Empty(AFA->AFA_PRODUT)  
						If !Empty(AFA->AFA_PRODUT)
							nPos:= aScan(aProdutos,{|x| x[2] == AFA->AFA_PRODUT	.And. x[5] =="P" })
						Else
							nPos:= aScan(aProdutos,{|x| x[2] == AFA->AFA_RECURS	.And. x[5] =="R" })
						Endif							
						If (nPos > 0)
							aProdutos[nPos,3]+= nQuantAFA
							aProdutos[nPos,4]+= nQuantAFA * AFA->AFA_CUSTD
						Elseif AFA->AFA_PRODUT >= mv_par04 .and. AFA->AFA_PRODUT <= mv_par05
							If  !Empty(AFA->AFA_PRODUT)
								aAdd(aProdutos,{"",AFA->AFA_PRODUT,nQuantAFA,AFA->AFA_CUSTD*nQuantAFA,"P",QbTexto(Posicione("SB1",1,xFilial("SB1")+AFA->AFA_PRODUT,"B1_DESC"), 030, " ")})
							Else
								aAdd(aProdutos,{"",AFA->AFA_RECURS,nQuantAFA,AFA->AFA_CUSTD*nQuantAFA,"R",QbTexto(IIF(Empty(cObfNRecur),Posicione("AE8",1,xFilial("AE8")+AFA->AFA_RECURS,"AE8_DESCRI"),cObfNRecur), 030, " ")})
							Endif
						Endif
					Endif
				EndIf
				//Valida se a op��o de imprimir recursos sem produto seja 2(nao) no mv_par10  
				//e se na tabela AFA o recurso est� sem produto na coluna AFA_PRODUT
				If mv_par10 == 2 .And. Empty(AFA->AFA_PRODUT) 
					dbSkip()
					Loop					
				Endif		   
			EndIf

			//////////////////////////  R4

			oItemTarefa:Init()
			// finaliza a sessao se mudar de tarefa
			If oTarefa:lPrinting .And. (mv_par09 == 2) .And. (cTarefa <> AFA->AFA_TAREFA )
				oTarefa:Finish()
			EndIf

			// verifica se a impressao e por projeto ou por tarefa
			If (mv_par09 == 2) .And. (cTarefa <> AFA->AFA_TAREFA)
				cTarefa:= AFA->AFA_TAREFA
				AF9->(dbSetOrder(1))
				AF9->(MsSeek(xFilial("AF9") + (cAliasAF8)->AF8_PROJET + (cAliasAF8)->AF8_REVISA + cTarefa))

				oReport:ThinLine()

				If ! oTarefa:lPrinting
					oTarefa:Init()
					oTarefa:PrintLine()
				EndIf

				oReport:ThinLine()

			EndIf    
			
			IF !Empty(AFA->AFA_PRODUT)
				
				dbSelectArea("SB1")
				dbSetOrder(1)
				SB1->(dbseek(xFilial("SB1")+ AFA->AFA_PRODUT ))
				
			ELSE
				
				dbSelectArea("AE8")
				dbSetOrder(1)
				AE8->(dbseek(xFilial("AE8")+ AFA->AFA_RECURS )) 					
								
			ENDIF
			
			dbSelectArea("AFA")
			
			If AFA->AFA_PRODUT >= mv_par04 .and. AFA->AFA_PRODUT <= mv_par05
				oItemTarefa:PrintLine()
			EndIf
			
			If oTarefa:lPrinting
				oTarefa:Finish()
			EndIf
			
			dbSkip()
			
		End
	EndIf
	AF8->(DbGoTo(nRecAF8))
	dbSelectArea("AF9")
	AF9->( dbSkip() )
End

Return  


//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta fun��o deve utilizada somente ap�s 
    a inicializa��o das variaveis atravez da fun��o FATPDLoad.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, L�gico, Retorna se o campo ser� ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun��o que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
