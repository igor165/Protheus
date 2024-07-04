#INCLUDE "PCOR010.CH"
#INCLUDE "PROTHEUS.CH"
/*/
_F_U_N_C_苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲UNCAO    � PCOR010  � AUTOR � Edson Maricate        � DATA � 07-01-2004 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰ESCRICAO � Programa de impressao da planilha orcamentaria.              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� USO      � SIGAPCO                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡DOCUMEN_ � PCOR010                                                      潮�
北砡DESCRI_  � Programa de impressao da planilha orcamentaria.              潮�
北砡FUNC_    � Esta funcao devera ser utilizada com a sua chamada normal a  潮�
北�          � partir do Menu do sistema.                                   潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PCOR010(aPerg)

PCOR010R4(aPerg)

Return

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  砅COR010R4 � Autor 砅aulo Carnelossi       � Data �31/05/2006潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矲uncao do Relatorio para release 4 utilizando obj tReport   潮�
北�          �                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   矱xpO1: Objeto do relat髍io                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砃enhum                                                      潮�
北�          矱xpA1: Array com conteudo dos MV_PAR do Pergunte            潮�
北�          �                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�   DATA   � Programador   矼anutencao efetuada                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�          �               �                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PCOR010R4(aPerg)
Local aArea		:= GetArea()
Local cAliasAK1 := "AK1"
Local cAliasAKE := "AKE"
Local cAliasAK3 := "AK3"

Private cRevisa

Default aPerg := {}

//OBSERVACAO NAO TIRAR A LINHA ABAIXO POIS SERA UTILIZADA NA CONSULTA PADRAO AKE1
Private M->AKR_ORCAME := Replicate("Z", Len(AKR->AKR_ORCAME))

If Len(aPerg) >  0
	aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矷nterface de impressao                                                  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
oReport := ReportDef( @cAliasAK1, @cAliasAK3, @cAliasAKE )
If !Empty(oReport:uParam)
	Pergunte(oReport:uParam,.F.)
EndIf	
oReport:PrintDialog()

RestArea(aArea)
	
Return

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  砅coR010Avalia� Autor 砅aulo Carnelossi    � Data �31/05/2006潮�
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矲uncao de validacao do botao OK da print Dialog obj tReport 潮�
北�          �                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   矱xpO1: Objeto do relat髍io                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砃enhum                                                      潮�
北�          矱xpA1: Array com conteudo dos MV_PAR do Pergunte            潮�
北�          �                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�   DATA   � Programador   矼anutencao efetuada                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�          �               �                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function PcoR010Avalia()
Local lOk := .T.

	dbSelectArea("AK1")
	dbSetOrder(1)
	If !Empty(MV_PAR01) .And. !Empty(MV_PAR02)
		If  MsSeek(xFilial()+MV_PAR01)
			
			If !Empty(MV_PAR02)
				dbSelectArea("AKE")
				dbSetOrder(1)
				If ! MSSeek(xFilial()+MV_PAR01+MV_PAR02)
					MsgStop(STR0013)	// Revisao nao encontrada. Verifique!
					lOk := .F.
				Else
					cRevisa := MV_PAR02
				EndIf
				dbSelectArea("AK1")
			Else			
				While AK1->(! Eof() .And. AK1_FILIAL+AK1_CODIGO == xFilial("AK1")+MV_PAR01)
					cRevisa	:= AK1->AK1_VERSAO
					nRecAK1 := AK1->(Recno())
					AK1->(dbSkip())
				End
			AK1->(dbGoto(nRecAK1))
			EndIf      
			
			If lOk
				lOk := (PcoVerAcessoPlan(2) > 0 )
			EndIf	
		EndIf
	Else
		lOk:=.F.
	EndIf

Return(lOk)

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  砇eportDef � Autor 砅aulo Carnelossi       � Data �31/05/2006潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矨 funcao estatica ReportDef devera ser criada para todos os 潮�
北�          硆elatorios que poderao ser agendados pelo usuario.          潮�
北�          �                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   矱xpO1: Objeto do relat髍io                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砃enhum                                                      潮�
北�          矱xpC1: Alias da tabela de Planilha Orcamentaria (AK1)       潮�
北�          矱xpC2: Alias da tabela de Contas da Planilha (Ak3)          潮�
北�          矱xpC3: Alias da tabela de Revisoes da Planilha (AKE)        潮�
北�          �                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�   DATA   � Programador   矼anutencao efetuada                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�          �               �                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function ReportDef(cAliasAK1, cAliasAK3, cAliasAKE)

Local oReport
Local oPlanilha
Local oContasOrc

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矯riacao do componente de impressao                                      �
//�                                                                        �
//砊Report():New                                                           �
//矱xpC1 : Nome do relatorio                                               �
//矱xpC2 : Titulo                                                          �
//矱xpC3 : Pergunte                                                        �
//矱xpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//矱xpC5 : Descricao                                                       �
//�                                                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
oReport := TReport():New("PCOR010",STR0012,"PCR010", ;
			{|oReport| If(PcoR010Avalia(),ReportPrint(oReport, @cAliasAK1, @cAliasAK3, @cAliasAKE ),oReport:Finish())},;
			STR0012 )
//"Planilha Resumida"

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矯riacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//砊RSection():New                                                         �
//矱xpO1 : Objeto TReport que a secao pertence                             �
//矱xpC2 : Descricao da se鏰o                                              �
//矱xpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se玢o.                   �
//矱xpA4 : Array com as Ordens do relat髍io                                �
//矱xpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//矱xpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
oPlanilha := TRSection():New(oReport,STR0012,{cAliasAK1}, {}, .F., .F.)
//Nao fazer filtro no AK1 pois as perguntas so permitem um orcamento
oPlanilha:SetNoFilter({cAliasAK1})

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矯riacao da celulas da secao do relatorio                                �
//�                                                                        �
//砊RCell():New                                                            �
//矱xpO1 : Objeto TSection que a secao pertence                            �
//矱xpC2 : Nome da celula do relat髍io. O SX3 ser� consultado              �
//矱xpC3 : Nome da tabela de referencia da celula                          �
//矱xpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//矱xpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//矱xpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//矱xpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//矱xpB8 : Bloco de c骴igo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
TRCell():New(oPlanilha,	"AK1_CODIGO"	,cAliasAK1,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAK1)->AK1_CODIGO})
TRCell():New(oPlanilha,	"AK1_VERSAO"	,cAliasAK1,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| cRevisa})
TRCell():New(oPlanilha,	"AK1_DESCRI"	,cAliasAK1,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAK1)->AK1_DESCRI})
TRCell():New(oPlanilha,	"AK1_INIPER"	,cAliasAK1,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAK1)->AK1_INIPER})
TRCell():New(oPlanilha,	"AK1_FIMPER"	,cAliasAK1,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAK1)->AK1_FIMPER })
oPlanilha:SetHeaderPage()

oReport:OnPageBreak({||oPlanilha:PrintLine()})

oContaOrc := TRSection():New(oReport,STR0014  ,{cAliasAK3,"AK5"},/*aOrdem*/,.F.,.F.)//"Contas Orcamentarias"
TRCell():New(oContaOrc	,"AK3_CO"		,cAliasAK3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| PcoRetCo((cAliasAK3)->AK3_CO)})
TRCell():New(oContaOrc	,"AK3_NIVEL"	,cAliasAK3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAK3)->AK3_NIVEL})
TRCell():New(oContaOrc	,"AK3_DESCRI"	,cAliasAK3,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasAK3)->(REPLICATE(".",(VAL(AK3_NIVEL)-1)*3)+AK3_DESCRI)})
TRCell():New(oContaOrc	,"AK3_TIPO"		,cAliasAK3,/*Titulo*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/,{|| (cAliasAK3)->(If(AK3_TIPO == "2",STR0011,STR0010))}) //"Analitica"###"Sintetica"
TrPosition():New(oContaOrc, "AK5", 1, {|| xFilial("AK5") + (cAliasAK3)->AK3_CO }) 

//Nao fazer filtro no AK5 
//oPlanilha:SetNoFilter({cAliasAK3,"AK5"})

//oContaOrc:SetLineCondition({||  AK5->(Found())})

Return(oReport)

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  砇eportPrint� Autor 砅aulo Carnelossi      � Data �29/05/2006潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矨 funcao estatica ReportDef devera ser criada para todos os 潮�
北�          硆elatorios que poderao ser agendados pelo usuario.          潮�
北�          硄ue faz a chamada desta funcao ReportPrint()                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   矱xpO1: Objeto do relat髍io                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砃enhum                                                      潮�
北�          矱xpO1: Objeto TReport                                       潮�
北�          矱xpC2: Alias da tabela de Planilha Orcamentaria (AK1)       潮�
北�          矱xpC3: Alias da tabela de Contas da Planilha (Ak3)          潮�
北�          矱xpC4: Alias da tabela de Revisoes da Planilha (AKE)        潮�
北�          �                                                            潮�
北�          �                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�   DATA   � Programador   矼anutencao efetuada                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�          �               �                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function ReportPrint( oReport, cAliasAK1, cAliasAK3, cAliasAKE )
Local oPlanilha := oReport:Section(1)
Local oContaOrc := oReport:Section(2)

oReport:SetMeter((cAliasAK1)->(LastRec()))
	
dbSelectArea(cAliasAK1)
oPlanilha:Init()
oContaOrc:Init()

dbSelectArea(cAliasAK3)
dbSetOrder(3)
MsSeek(xFilial()+(cAliasAK1)->AK1_CODIGO+cRevisa+"001")
While (cAliasAK3)->(!Eof() .And. 	AK3_FILIAL+AK3_ORCAME+AK3_VERSAO+AK3_NIVEL==;
					xFilial("AK3")+(cAliasAK1)->AK1_CODIGO+cRevisa+"001")

	If oReport:Cancel()
		Exit
	EndIf
				
	(cAliasAK3)->(PCOR010_ItR4(AK3_ORCAME,AK3_VERSAO,AK3_CO,oReport,cAliasAK1,cAliasAK3))

	dbSelectArea(cAliasAK3)
	dbSkip()
	
	oReport:IncMeter()

End

oContaOrc:Finish()
oPlanilha:Finish()

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    砅COR010_ItR4� Autor � Paulo Carnelossi    � Data �31/05/06  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矲uncao de impressao das contas da planilha orcamentaria.    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   砅COR010_It(AK3_ORCAME,AK3_VERSAO,AK3_CO,oReport)            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� lEnd - Variavel para cancelamento da impressao pelo usuario潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function PCOR010_ItR4(cOrcame, cVersao, cCO, oReport, cAliasAK1, cAliasAK3)
Local aArea		:= GetArea()
Local aAreaAK3	:= (cAliasAK3)->(GetArea())
Local oContaOrc := oReport:Section(2)

// Se o centro Orcamentario pertence ao filtro que foi selecionado
If ((cAliasAK3)->AK3_CO >= SubStr(MV_PAR03,1,TamSX3('AK3_CO')[1])) .AND. ((cAliasAK3)->AK3_CO <= SubStr(MV_PAR04,1,TamSX3('AK3_CO')[1]) )
	// Se o Nivel pertence ao filtro que foi selecionado
	If ((cAliasAK3)->AK3_NIVEL >= MV_PAR05) .AND. ((cAliasAK3)->AK3_NIVEL <= MV_PAR06 )
		
		oContaOrc:PrintLine()

	EndIf

EndIf

dbSelectArea(cAliasAK3)
dbSetOrder(2)

MsSeek(xFilial()+cOrcame+cVersao+cCO)

While (cAliasAK3)->(!Eof() .And. ;
		AK3_FILIAL+AK3_ORCAME+AK3_VERSAO+AK3_PAI == ;
		xFilial("AK3")+cOrcame+cVersao+cCO)

	If oReport:Cancel()
		Exit
	EndIf

	(cAliasAK3)->(PCOR010_ItR4(AK3_ORCAME, AK3_VERSAO, AK3_CO, oReport, cAliasAK1, cAliasAK3))

	dbSelectArea(cAliasAK3)
	dbSkip()
	
	oReport:IncMeter()

End

RestArea(aAreaAK3)
RestArea(aArea)

Return