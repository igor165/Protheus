#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"     
#INCLUDE "CTBS040.CH"     
#INCLUDE "ECD.CH"

//Compatibilização de fontes 30/05/2018

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CTBS040    ³ Autor ³				        ³ Data ³09/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³														      ³±±
±±³          ³                                                     		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 											                  ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBS040( cEmp , oTree , bIncTree )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Perguntas utilizadas no Wizard³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aPerEsc 	:= {}  
Local aPerg		:= {} 
Local aResp		:= {}
Local aValid	:= {}
Local oOk 		:= LoadBitmap( GetResources(), "LBOK")
Local oNo		:= LoadBitmap( GetResources(), "LBNO")
Local oEmp 		:= Nil           
Local aFils		:= {}
Local oFil 		:= Nil
Local lProcessa := .F.     
Local lRet		:= .F.
Local aParLeiaute, aRespLeiaute
Local aCposLayt2, nX, cCpoLayt2
Local aCposLayt3
Local cCpoLayt3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Respostas referente as perguntas utilizadas no Wizard³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private aResExpor	:= Array(4)   
Private oWzrdEcd	:= Nil
Private oErr			:= Nil
Private aErrEcd		:= {{"Erro"}}
Private lLeiaute2 := .F.
Private lLeiaute3 := .F.
Private lLeiaute4 := .F.
Private lLeiaute5 := .F.
Private lLeiaute6 := .F.
Private lLeiaute7 := .F.
Private lLeiaute8 := .F.
Private lLeiaute9 := .F.
Private lMoedfun	:= .F.
Private aResEsc		:= Array(2)

Default bIncTree   	:= {||.T.}

aHeader := ARRAY(5)

aHeader[1]	:= ""  		
aHeader[2] 	:= STR0014 //"Filial"
aHeader[3] 	:= STR0015 //"Razão Social"
aHeader[4]	:= STR0016 //"CNPJ"
aHeader[5]	:= ""

aFils := GetEmpEcd( cEmp )


	aParLeiaute := {}
	aRespLeiaute := {2}
	aAdd(aParLeiaute ,{3,STR0023,9,{STR0024,STR0025,STR0047,STR0066,STR0067,STR0074,STR0075,STR0093,STR0098},90,"",.T.,.T.}) //"Informe o leiaute da ECD ?"##"Leiaute 1"##"Leiaute 2"##"Leiaute 3"##"Leiaute 4"##"Leiaute 5"##"Leiaute 6"##"Leiaute 7"##"Leiaute 8"
	If ParamBox( aParLeiaute,"", @aRespLeiaute)
		If aRespLeiaute[1] == 2
			lLeiaute2  := .T.
		ElseIf aRespLeiaute[1] == 3
			lLeiaute2  := .T.
			lLeiaute3  := .T.
		ElseIf aRespLeiaute[1] == 4
			lLeiaute2  := .T.
			lLeiaute3  := .T.
			lLeiaute4  := .T.
		ElseIf aRespLeiaute[1] == 5
			lLeiaute2  := .T.
			lLeiaute3  := .T.
			lLeiaute4  := .T.	  
			lLeiaute5  := .T.
		ElseIf aRespLeiaute[1] == 6
			lLeiaute2  := .T.
			lLeiaute3  := .T.
			lLeiaute4  := .T.	  
			lLeiaute5  := .T.	
			lLeiaute6  := .T.
		ElseIf aRespLeiaute[1] == 7
			lLeiaute2  := .T.
			lLeiaute3  := .T.
			lLeiaute4  := .T.	  
			lLeiaute5  := .T.	
			lLeiaute6  := .T.
			lLeiaute7  := .T.
		ElseIf aRespLeiaute[1] == 8
			lLeiaute2  := .T.
			lLeiaute3  := .T.
			lLeiaute4  := .T.	  
			lLeiaute5  := .T.	
			lLeiaute6  := .T.
			lLeiaute7  := .T.
			lLeiaute8  := .T.
		ElseIf aRespLeiaute[1] == 9
			lLeiaute2  := .T.
			lLeiaute3  := .T.
			lLeiaute4  := .T.	  
			lLeiaute5  := .T.	
			lLeiaute6  := .T.
			lLeiaute7  := .T.
			lLeiaute8  := .T.
			lLeiaute9  := .T.	
		EndIf

		If !VldCSQL7(aRespLeiaute)
			Return
		EndIf

  Else
		ALERT(STR0028)  //"Deve ser selecionado um leiaute para ECD. Verifique!")
		Return
  EndIf     
  
	aPerEsc 	:= ParamEsc()
	aPerg		:= aPerEsc[1] 
	aResp		:= aPerEsc[2]
	aValid		:= aPerEsc[3]    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da Interface                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// P1
DEFINE WIZARD oWzrdEcd ;
	TITLE  (STR0001) ; //"Assistente de Importação de Arquivos de Diarios Auxiliares"  
	HEADER (STR0002) ; //"Atenção"		
	MESSAGE(STR0003) ; //"O objetivo desta rotina é importar arquivos textos contendo dados dos diarios auxiliares." 
	TEXT (STR0004) ; //"Siga atentamente os passos deste assistente para efetuar a importação corretamente." 
   	NEXT {|| .T.} 
   	
//P2
If GetType() == "ECD"
	aResEsc[1] := 1
	If lLeiaute9
		aResEsc[2] := 9
	ElseIf lLeiaute8
		aResEsc[2] := 8
	ElseIf lLeiaute7
		aResEsc[2] := 7
	ElseIf lLeiaute6
		aResEsc[2] := 6
	ElseIf lLeiaute5 //Deixando como padrão a ultima versão selecionada no painel anterior
		aResEsc[2] := 5
	ElseIf lLeiaute3
		aResEsc[2] := 3
	ElseIf lLeiaute2
		aResEsc[2] := 2
	EndIf
ElseIf GetType() == "FCO"
	aResEsc[1] := 2
EndIf  

CREATE PANEL oWzrdEcd  ;
	HEADER (STR0029) ; //"Quais são as filiais que essa empresa centralizadora?"
	MESSAGE ""	;
	BACK {|| .T.} ;
	NEXT {|| ValidaEmpEcd(aFils)} ;
	PANEL

 	oFil := TWBrowse():New( 0.5, 0.5 , 280, 130,Nil,aHeader, Nil, oWzrdEcd:GetPanel(2), Nil, Nil, Nil,Nil,;
 					      {|| aFils := EmpTrocEcd( oFil:nAt, aFils, .T. ), oFil:Refresh() })      

	oFil:SetArray( aFils )
	
	oFil:bLine := {|| {;
					If( aFils[oFil:nAt,1] , oOk , oNo ),;
						aFils[oFil:nAt,3],;
						aFils[oFil:nAt,4],;
						aFils[oFil:nAt,5];
					}}
					

// P3
CREATE PANEL oWzrdEcd  ;
	HEADER (STR0005) ; //Escolha o arquivo a ser importado."
	MESSAGE "" ;
	BACK {|| .T.} ;
	NEXT {|| VldParams(aResp,aValid) .And. VldSubPar(aResp) .AND. ;
	IIF( (lLeiaute8 .And. aResp[22] == 2),(ApMsgInfo(STR0097, STR0096, ), .T.), .T. )} ; // Mostrar mensagem caso o parâmetro 'Existe mudança no plano referencial?' esteja como 'Não' "
	PANEL                                                                                           

	ParamBox( aPerg,"",aResp,,,,,,oWzrdEcd:GetPanel(3),,.F.)  
  

// P4
CREATE PANEL oWzrdEcd  ;
	HEADER (STR0002) ; //"Atenção"
  	MESSAGE "" ;   
  	BACK {|| .T.} ;
   	NEXT {|| .T.} ;
 	FINISH {|| lProcessa := .T. ,.T.}    
 	
@ 030,010 SAY (STR0006) SIZE 270,020  PIXEL OF oWzrdEcd:GetPanel(4) //"Clique no botão Finalizar para iniciar a importação do arquivo." 	                                                                                       
	    	
ACTIVATE WIZARD oWzrdEcd CENTERED

If lProcessa
If lLeiaute4 .and. aResp[16]==1
	DbSelectArea( "CS0" )	
	If ColumnPos( 'CS0_MOEFUN' )  == 0
		MsgAlert(STR0076) //"Ambiente não preparado para trabalhar com moeda funcional favor atualizar dicionarios." 
		lMoedfun :=.F.
	Else
		lMoedfun:=.T.
	EndIf
Endif  

 If !lLeiaute2
 	Processa({|| lRet := ECDImpLivro(cEmp, aFils, aResp[1] , aResp[4] , aResp[5] , aResp[6], aResp[2],aResp[3],,oTree,bIncTree,        ,        ,        ,         ,         ,         ,         ,         ,aResp[07] )}," ")
 ElseIf lLeiaute8
	Processa({|| lRet := ECDImpLivro(cEmp, aFils, aResp[1] , aResp[4] , aResp[5] , aResp[6], aResp[2],aResp[3],,oTree,bIncTree,aResp[7],aResp[8],aResp[9],aResp[10],aResp[11],aResp[12],aResp[13],aResp[14],aResp[15],aResp[17],aResp[19],aResp[20],aResp[21],aResp[22])}," ") 
 ElseIf lLeiaute4
	Processa({|| lRet := ECDImpLivro(cEmp, aFils, aResp[1] , aResp[4] , aResp[5] , aResp[6], aResp[2],aResp[3],,oTree,bIncTree,aResp[7],aResp[8],aResp[9],aResp[10],aResp[11],aResp[12],aResp[13],aResp[14],aResp[15],aResp[17],aResp[19],aResp[20] )}," ") 
 Else
	Processa({|| lRet := ECDImpLivro(cEmp, aFils, aResp[1] , aResp[4] , aResp[5] , aResp[6], aResp[2],aResp[3],,oTree,bIncTree,aResp[7],aResp[8],aResp[9],aResp[10],aResp[11],         ,         ,         ,aResp[12] )}," ") 
 EndIf	
EndIf

If lRet
	msgAlert(STR0030)  //"Importação finalizada."
End

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ParamEsc  ºAutor  ³					 º Data ³  09/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua o preenchimento do array do CheckBox e retorna o     º±±
±±º          ³mesmo para ser apresentado no Wizard atraves da função 	  º±±
±±º          ³parambox      											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ParamEsc()
Local aParamEsc 	:= {}
Local aPerg 		:= {}
Local aResp 		:= {}
Local aValid		:= {}
Local aIndIniPer  	:= {STR0031,STR0032,STR0033,STR0034}  //"0-Inicio no primeiro dia do ano"##"1-Abertura"##"2-Resultante Cisao/Fusao ou remanescente..."##"3-Inicio Obrigatoriedade Entrega "
Local aEcdFinEscr 	:= {}     //"Indicador de finalidade da escrituração:"##"0-Original"##"1-Substituta com NIRE"##"2-Substituta sem NIRE"##"3-Substituta com troca de NIRE"
Local aEcdIndNire 	:= {STR0039,STR0040}  					//"0-Empresa não possui NIRE"##"1-Empresa possui NIRE"
Local aTabEntid 		:= { 	STR0049,;  //"1-PJ em Geral (L100A + L300A da ECF)"
													STR0050,;  //"2-PJ em Geral–Lucro Presumido (P100 + P150 da ECF)"
													STR0051,;  //"3-Financeiras (L100B + L300B da ECF)"
													STR0052,;  //"4-Seguradoras (L100C + L300C da ECF)"
													STR0053,;  //"5-Imunes e Isentas em Geral (U100A + U150A da ECF)"
													STR0054,;  //"6-Financeiras-Imunes e Isentas (U100B + U150B da ECF)"
													STR0055,;  //"7-Seguradoras-Imunes e Isentas (U100C + U150C da ECF)"
													STR0056,;  //"8-Entidades Fechadas de Previdencia Complementar (U100D + U150D da ECF)"
													STR0057 }  //"9-Partidos Politicos (U100E + U150E da ECF)" 
					
Local aMotSubst			:= {STR0077,; //"000=Não se aplica"
												STR0078,; //"001=Mudanças de saldos"
												STR0079,; //"002=Alteração assinatura"
												STR0080,; //"003=Alteração Dem. contábil"
												STR0081,; //"004=Alteração Forma Escrit. contábil"
												STR0082,; //"005=Alteração do número do livro"
												STR0083}  //"099=Outros"  					

If lLeiaute5 .Or. lLeiaute6
	aEcdFinEscr 	:= {STR0068,STR0069} 
	aAdd(aTabEntid,STR0073)
Else
	aEcdFinEscr 	:= {STR0035,STR0036,STR0037,STR0038}      //"Indicador de finalidade da escrituração:"##"0-Original"##"1-Substituta com NIRE"##"2-Substituta sem NIRE"##"3-Substituta com troca de NIRE"
EndIf	   	

AADD(aPerg,{6,(STR0007)	,Space(99)	,"",,"",99,.T.,(STR0008),"",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE})//*"Qual arquivo"*//*"Arquivo .txt |*.txt"*/
AADD(aPerg,{1,(STR0020)	,CTOD("")	,"","","",,50,.T.}) //"Data Inicial "
AADD(aPerg,{1,(STR0021)	,CTOD("")	,"","","",,50,.T.}) //"Data Final  "
AADD(aPerg,{1,(STR0041)	,Space(CSV->(TamSx3("CSV_CODLAY")[1]))	,"@!","ExistCpo('CSV')","CSV",,10,.T.}) //"Layout"
AADD(aPerg,{1,(STR0017)	,Space(5)	,"@E 99999","","",,60,.T.}) //"Numero de Ordem do Livro"
AADD(aPerg,{1,(STR0018)	,Space(80)	,"","","",,100,.T.}) //"Natureza do Livro "

If lLeiaute2
	aAdd(aPerg,{3,(STR0042)			,1,aIndIniPer,120,"",.T.}) //"Indicador Inicio de Periodo"
	aAdd(aPerg,{3,(STR0043)			,2,aEcdIndNire,120,"",.T.}) //"Indicador de existência de NIRE"
	aAdd(aPerg,{3,(STR0044)			,1,aEcdFinEscr,120,"",.T.}) //"Indicador de finalidade da escrituração"
	aAdd(aPerg,{1,(STR0045)			,Space(40),"","","",,110,.F.}) //"Hash da Escrituração Substituida"
	aAdd(aPerg,{1,STR0046			,Space(11),"","","","BloqOpc()",110,.F.})  	//"NIRE da Escrituração Substituida
EndIf

If lLeiaute2
	aResp := {Space(99),CTOD(""),CTOD(""),Space(CSV->(TamSx3("CSV_CODLAY")[1])),Space(5),Space(80),1,2,1,Space(40),Space(11)}
	aValid := {.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.F.,.F.}
Else
	aResp := {Space(99),CTOD(""),CTOD(""),Space(CSV->(TamSx3("CSV_CODLAY")[1])),Space(5),Space(80)}
EndIf

If lLeiaute3
	aIndGdePorte 	:= { STR0058, STR0059 }  //"0 – Empresa não é entidade sujeita a auditoria independente."##"1 – Empresa é entidade sujeita a auditoria independente."
	aEcdTipoSCP 	:= { STR0060, STR0061, STR0062 }  //"0 – ECD de empresa não participante de SCP como sócio ostensivo.","1 – ECD de empresa participante de SCP como sócio ostensivo.","2 – ECD da SCP."}
	aAdd(aPerg,{3,STR0063			,1,aIndGdePorte,190,"",.T.}) //"Indicador Empr.Grande Porte"
	aAdd(aPerg,{3,STR0064			,2,aEcdTipoSCP,190,"",.T.}) //"Tipo da ECD (SCP)"
	aAdd(aPerg,{3,STR0065			,1,aTabEntid,190,"",.T.}) //"Plano Contas Referencial"
	aAdd(aResp, 1 )
	aAdd(aResp, 1 )
	aAdd(aResp, 1 )
	aValid := {.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.F.,.F.,.F.,.F.,.F.}
EndIf

aAdd(aPerg,{1,STR0086,Space(CS0->(TamSx3("CS0_CODPLA")[1])),"@!","","CVN1",,50,.F.})//
aAdd(aResp,Space(CT1->(TamSx3("CT1_CONTA")[1])))
If lLeiaute4
	aAdd(aPerg,{3,(STR0087)			,1,{"Sim","Não"},120,"",.T.}) //"Indicador de existência de NIRE"~
	aAdd(aResp, 2 )
	AADD(aPerg,{1,(STR0088)	,CTOD("")	,"","","",,50,.T.}) //"Data de Apuração"
	aAdd(aResp, CTOD("") )	
	aValid := {.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.T.}	
EndIf

aAdd(aPerg,{3,STR0072,1,{STR0070,STR0071},190,"",.T.,"BloqOpc()"}) //"Escriturações Contábeis Consolidadas?"
aAdd(aPerg,{1,STR0084,Space(500),"@!",,"DIR",/*"EcdVldSubs()"*/,100,.F.}) //Termo de Substituição da ECD
aAdd(aPerg,{3,STR0085,1,aMotSubst,190,"",.T.,"lLeiaute7"})       //Motivo de Substituição
aAdd(aResp,2)	
aAdd(aResp,Space(500))
aAdd(aResp,1)
aValid := {.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.T.,.T.,.F.,.F.}

If lLeiaute8
	aAdd(aPerg,{3,STR0094,1,{STR0070,STR0071},190,"",.T.}) //"Ocorreu mudança no Plano de Contas?"
    aAdd(aResp,2)

	aAdd(aPerg,{3,STR0095,1,{STR0070,STR0071},190,"",.T.}) //"Existe amarração com Plano Referencial?"
    aAdd(aResp,1)
	aValid := {.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.T.,.T.,.F.,.F.,.F.,.F.}
EndIf


AADD(aParamEsc, aPerg)
AADD(aParamEsc, aResp)
AADD(aParamEsc, aValid)

Return aParamEsc
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldParams ºAutor  ³Microsiga           º Data ³  09/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se foi selecionado algum arquivo                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldParams(aResp,aValid)
Local lRet := .T.
Local nX   := 0

Default aValid := {}

If ! Empty(aValid)
	For nX := 1 To Len(aResp)
		
		If aValid[nX] .And. Empty(aResp[nX])
			
			MsgStop(STR0019) //Campos obrigatorios nao preenchidos.
			lRet := .F.
			Exit
		EndIf
		
	Next
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} BloqOpc
Bloqueia campos inutilizáveis no layout 5

@author André Brito	
   
@version P11
@since   22/03/2017
@return  lBloq - Lógico 
/*/
//-------------------------------------------------------------------

Function BloqOpc()

Local lBloq := .T.

If lLeiaute5
	lBloq := .F.
EndIf

Return lBloq
/*/{Protheus.doc} VldSubPar
Valida revisão substituta do livro Z 

@author André Brito	
   
@version P11
@since   22/03/2017
@return  lBloq - Lógico 
/*/
Static Function VldSubPar(aResp)
Local lRet 		:= .T.
DEFAULT aResp := {}

If Len(aResp)>8 .And. ValType(aResp[9]) == "N"
	If aResp[9]==1
		If Len(aResp)>18 .And. !Empty(aResp[19])
		MsgStop(STR0092) //"Para escrituração original não é permitido preencher termo de substituição."
			lRet := .F.
		EndIf
	ElseIf aResp[9]==2
		If Empty(aResp[10])
			MsgStop(STR0089)
			lRet := .F.
		EndIf
		If lRet .And. Len(aResp)>18 .And. Empty(aResp[19])
			MsgStop(STR0090)
			lRet := .F.
		EndIf
		If lRet .And. lLeiaute7 .And. Len(aResp)>19 .And. aResp[20]==1
			MsgStop(STR0091)
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet
