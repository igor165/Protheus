#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include "GPEM780.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPEM780 	³ Autor ³ Marcos Kato		      ³ Data ³   25.07.08    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao do dados do Balanco Social de Portugal			         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Portugal                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tiago Malta ³07/01/10  ³00280/2010 ³	Ajuste no filtro do select tabela RGQ.   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function GPEM780()
Private ccadastro	:= STR0001//"Balanco Social"
Private aSays 	  	:= {}, aButtons  	:= {}, aLogProc  	:= {}
Private cExtRel   	:= ".##R"
Private cParFilial	:= cFilAnt, cParAnoBas	:=Substr(Dtos(dDataBase),1,4),cParDesFil := " ",  cParEmail:=Space(50)
Private oParFilial , oParDesFil, oParAnoBas,oParEmail

nOpca:=0

cPathFile 		:= ( __RelDir + STR0002 + cExtRel )//"GPER780"

ChkFile("PA0")
ChkFile("PA1")
DbSelectArea("SM0")


AADD(aSays,OemToAnsi(STR0003))//Este programa ira gerar os dados do Balanço Social
AADD(aSays,OemToAnsi(STR0004))//da Empresa para ser entregue ao Ministerio do Trabalho
AADD(aSays,OemToAnsi(STR0005))//e da Solidariedade
AADD(aButtons, { 15,.T.,{|| If(File(cPathFile),(OurSpool(STR0002),Ms_Flush()),nOpca:=0)} } )//GPER780
AADD(aButtons, {  5,.T.,{|| (Pergunte(STR0006,.T.)) } } )//GPM780
AADD(aButtons, {  1,.T.,{|o| nOpca := 1,FechaBatch()}} )
AADD(aButtons, {  2,.T.,{|o| FechaBatch() }} )
//==================================================================================================================
//Montagem da Tela Inicial
//==================================================================================================================
FormBatch( cCadastro, aSays, aButtons )
	
//==================================================================================================================
//Caso haja a confirmacao do processo executa o processamento da geracao do arquivo
//==================================================================================================================
If nOpca == 1
	Processa({|lEnd| BalSocProc(@lEnd),STR0007})//Geracao dos dados do Balanco Social
Endif
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³BalSocProc³ Autor ³ Marcos Kato		      ³ Data ³   25.07.08    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processo da Geracao do Balanco Social de Portugal		         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Portugal                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³           ³											 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function BalSocProc()

Local cQuery:=""
Local lOk:=.T.
Private aLogProc:={}
DbselectArea("RGN")
RGN->(DbSetOrder(1))
RGN->(DbGoTop())
CONOUT(TIME())
If DbSeek(cParFilial+cParAnoBas)
	lOk:=MsgNoYes(STR0007+cParAnoBas+".",STR0008)//Ja foi processado a geracao do Balanco Social do Ano#Deseja prosseguir?
	If lOk                                                                                            
		MsgRun(STR0009+cParAnoBas+".",STR0010, {||DeletaRGN(cParAnoBas)})//Apagando todos os dados gerados do Ano #Aguarde...
	Endif
Endif  

If lOk
cQuery:="SELECT RA_MAT,RA_SEXO,RA_ADMISSA,RA_SITFOLH,RA_DEMISSA,RA_NASC, SUBSTRING(RCC_CONTEU,78,1) TIPOCOBS,RA_HRSEMAN,RGG_NIVEL,RA_TPDEFFI, "
cQuery+="RA_DEFIFIS,RA_GRINRAI,RA_CPAISOR, '' RA_TIPOALT "
cQuery+="FROM "+RetSqlName("SRA")+" SRA "
cQuery+="INNER JOIN "+RetSqlName("RGG")+"  RGG ON "
cQuery+="RGG_FILIAL=RA_FILIAL "
cQuery+="AND RGG_CODIRC=RA_CODIRCT "
cQuery+="AND RGG_CODIGO=RA_CODCAT "
cQuery+="AND RGG.D_E_L_E_T_='' "     
cQuery+="LEFT JOIN "+RetSqlName("RCC")+" RCC ON "
cQuery+="RCC_CODIGO='S011' "
cQuery+="AND SUBSTRING(RCC_CONTEU,1,2)=RA_TIPOCO "
cQuery+="AND RCC.D_E_L_E_T_='' "     
cQuery+="WHERE SRA.D_E_L_E_T_='' "
cQuery+="AND RA_FILIAL='"+cParFilial+"' "
cQuery+="AND(RA_ADMISSA <= '"+cParAnoBas+"1231' AND RA_DEMISSA='') "
cQuery+="OR  (RA_DEMISSA >= '"+cParAnoBas+"0101' AND RA_DEMISSA <= '"+cParAnoBas+"1231') "
cQuery+="AND RA_TIPOCO<>'' "
	
cQuery := ChangeQuery(cQuery)
	
If Select("TRB")>0
	DbSelectArea("TRB")
	TRB->(DbCloseArea())
Endif
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.F.,.T.)
DbSelectArea("TRB")
TRB->(dbGoTop())

Do While TRB->(!Eof())
	
//==========================================================================================================
//Empresa
//==========================================================================================================
EmpresaBS()
//==========================================================================================================
//1-Emprego
//==========================================================================================================
EmpregoBS()
//==========================================================================================================
//2-Custo Pessoal
//==========================================================================================================
CusPesBS()
//==========================================================================================================
//3-Higiene e Seguranca
//==========================================================================================================
HigSegBS()
//==========================================================================================================
//4-Formacao Profissional
//==========================================================================================================
ForProBS()
//==========================================================================================================
//5-Protecao Social Complementar
//==========================================================================================================
ProSCoBS()   


TRB->(DbSkip())
End
aAdd( aLogProc, {"9",Replicate("*",130)           ,"00000000"} )
aAdd( aLogProc, {"9",STR0011                      ,"00000010"} )//Incosistencia  
aAdd( aLogProc, {"9",Replicate("*",130)           ,"00000020"} )
aAdd( aLogProc, {"9",Space(10)+STR0012            ,"10000000"} )//Categoria
aAdd( aLogProc, {"9",Space(10)+Replicate("-",120) ,"10000001"} )
aAdd( aLogProc, {"9"," "                          ,"19999998"} )
aAdd( aLogProc, {"9",Space(10)+Replicate("-",120) ,"19999999"} )
aAdd( aLogProc, {"9",Space(10)+STR0013            ,"20000000"} )//Grau de Instrucao
aAdd( aLogProc, {"9",Space(10)+Replicate("-",120) ,"20000001"} )
aAdd( aLogProc, {"9"," "                          ,"29999998"} )
aAdd( aLogProc, {"9",Space(10)+Replicate("-",120) ,"29999999"} )
aAdd( aLogProc, {"9",Space(10)+STR0014            ,"30000000"} )//Nacionalidade
aAdd( aLogProc, {"9",Space(10)+Replicate("-",120) ,"30000001"} )
aAdd( aLogProc, {"9"," "                          ,"39999998"} )
aAdd( aLogProc, {"9",Space(10)+Replicate("-",120) ,"39999999"} )


LogBalSoc(aLogProc)//Log de Ocorrencia
Endif
CONOUT(TIME())
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³EmpresaBS ³ Autor ³ Marcos Kato		      ³ Data ³   25.07.08    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processo da Geracao do Balanco Social de Portugal		         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Portugal                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcos Kato ³22/10/08  ³           ³Insercao M0_DSCCNA-Descr.Ativ.Economica e ³±±
±±³            ³          ³           ³M0_DSCCNA-Descr.Nat.Jur.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EmpresaBS()
Local aDadEmp:={}
Local nCon:=0,nMad:=0,nAco:=0,n02Jan:=0,n31Dez:=0,nMedAno:=0,nIntAno:=0
Local nJanAno:=0,nFevAno:=0,nMarAno:=0,nAbrAno:=0,nMaiAno:=0,nJunAno:=0,nJulAno:=0
Local nAgoAno:=0,nSetAno:=0,nOutAno:=0,nNovAno:=0,nDezAno:=0,nQtdPes:=0
Local nVab   :=0,nCusPes:=0,nAmoExe:=0,nProExe:=0,nCuPeFi:=0,nImpRen:=0,nResLiq:=0
Local cNomEmp:="",cEndEmp:="",cBaiEmp:="",cCidEmp:="",cEstEmp:="",cCepEmp:="",cTelEmp:="",cFaxEmp:="",cAtvEcoEmp:="",cNatJur:=""
//====================================================================================================
//Dados da Empresa - SIGAMAT
//====================================================================================================
cNomEmp:=IIF(EMPTY(SM0->M0_NOMECOM),SM0->M0_NOME,SM0->M0_NOMECOM)
cEndEmp:=IIF(EMPTY(SM0->M0_ENDCOB),SM0->M0_ENDENT,SM0->M0_ENDCOB)
cBaiEmp:=IIF(EMPTY(SM0->M0_ENDCOB),SM0->M0_BAIRENT,SM0->M0_BAIRCOB)
cCidEmp:=IIF(EMPTY(SM0->M0_CIDCOB),SM0->M0_CIDENT,SM0->M0_CIDCOB)
cEstEmp:=IIF(EMPTY(SM0->M0_ESTCOB),SM0->M0_ESTENT,SM0->M0_ESTCOB)	
cCepEmp:=IIF(EMPTY(SM0->M0_CEPCOB),SM0->M0_CEPENT,SM0->M0_CEPCOB)
cTelEmp:=SM0->M0_FAX
cFaxEmp:=SM0->M0_TEL         
cAtvEcoEmp:=SM0->M0_DSCCNA
cPesColJur:=SM0->M0_CGC
If !Empty(SM0->M0_CNAE)
	cNatJur:=Posicione("CC3",1,xFilial("CC3")+SM0->M0_CNAE,"CC3_DESC")             
Endif

Do While TRB->(!Eof())
	//Item 6 - Numero de pessoas ao servico
	If TRB->RA_ADMISSA<=cParAnoBas+"0101"
		n02Jan++//6.1 - Em 2 de Janeiro
	Endif
	If Empty(TRB->RA_DEMISSA) .Or.  (TRB->RA_DEMISSA >= cParAnoBas+"0101" .And. RA_DEMISSA <=cParAnoBas+"0131")
		n31Dez++//6.2 - 31 de Dezembro

		//SR8-Controle de Ausencia//VERIFICAR MELHOR A LOGICA
		DbSelectArea("SR8")
		SR8->(DbSetOrder(1))
		SR8->(DbgoTop())
		If DbSeek(cParFilial+TRB->RA_MAT)
			Do While SR8->(!EOF()) .And. SR8->R8_MAT==TRB->RA_MAT
				//RCM-Tipo de Ausencia
				DbSelectArea("RCM")
				RCM->(DbSetOrder(1))
				RCM->(DbgoTop())
				If DbSeek(cParFilial+SR8->R8_TIPOAFA) .And. Substr(Dtos(SR8->R8_DATAINI),1,4)==cParAnoBas ;
				.And. !(RCM->RCM_TIPOAF $ "1*4" ;//(1-Ausência sem vencimento e 4-Programação de período) e
				.And.Iif(Empty(SR8->R8_DATAFIM),.T.,DateDiffYear(SR8->R8_DATAINI,SR8->R8_DATAFIM) > 30)) //Se for superior a 30 dias o funcionario nao entra na contagem
					If (SUBSTR(Dtos(SR8->R8_DATAINI),5,2)>"01" .AND. nJanAno==0).OR.SUBSTR(Dtos(SR8->R8_DATAFIM),5,2)=="01"//Janeiro
						nJanAno++
					ElseIf (SUBSTR(Dtos(SR8->R8_DATAINI),5,2)>"02" .AND. nFevAno==0).OR.SUBSTR(Dtos(SR8->R8_DATAFIM),5,2)=="02"//Fevereiro
						nFevAno++
					ElseIf (SUBSTR(Dtos(SR8->R8_DATAINI),5,2)>"03" .AND. nMarAno==0).OR.SUBSTR(Dtos(SR8->R8_DATAFIM),5,2)=="03"//Marco
						nMarAno++
					ElseIf (SUBSTR(Dtos(SR8->R8_DATAINI),5,2)>"04" .AND. nAbrAno==0).OR.SUBSTR(Dtos(SR8->R8_DATAFIM),5,2)=="04"//Abril
						nAbrAno++
					ElseIf (SUBSTR(Dtos(SR8->R8_DATAINI),5,2)>"05" .AND. nMaiAno==0).OR.SUBSTR(Dtos(SR8->R8_DATAFIM),5,2)=="05"//Maio
						nMaiAno++
					ElseIf (SUBSTR(Dtos(SR8->R8_DATAINI),5,2)>"06" .AND. nJunAno==0).OR.SUBSTR(Dtos(SR8->R8_DATAFIM),5,2)=="06"//Junho
						nJunAno++
					ElseIf (SUBSTR(Dtos(SR8->R8_DATAINI),5,2)>"07" .AND. nJulAno==0).OR.SUBSTR(Dtos(SR8->R8_DATAFIM),5,2)=="07"//Julho
						nJulAno++
					ElseIf (SUBSTR(Dtos(SR8->R8_DATAINI),5,2)>"08" .AND. nAgoAno==0).OR.SUBSTR(Dtos(SR8->R8_DATAFIM),5,2)=="08"//Agosto
						nAgoAno++
					ElseIf (SUBSTR(Dtos(SR8->R8_DATAINI),5,2)>"09" .AND. nSetAno==0).OR.SUBSTR(Dtos(SR8->R8_DATAFIM),5,2)=="09"//Setembro
						nSetAno++
					ElseIf (SUBSTR(Dtos(SR8->R8_DATAINI),5,2)>"10" .AND. nOutAno==0).OR.SUBSTR(Dtos(SR8->R8_DATAFIM),5,2)=="10"//Outubro
						nOutAno++
					ElseIf (SUBSTR(Dtos(SR8->R8_DATAINI),5,2)>"11" .AND. nNovAno==0).OR.SUBSTR(Dtos(SR8->R8_DATAFIM),5,2)=="11"//Novembro
						nNovAno++
					ElseIf SUBSTR(Dtos(SR8->R8_DATAFIM),5,2)=="12"//Dezembro
						nDezAno++
					Endif
				Endif
				SR8->(DbSkip())
			End
			If (nJanAno+nFevAno+nMarAno+nAbrANo+nMaiAno+nJunAno+nJulAno+nAgoAno+nSetAno+nOutAno+nNovAno+nDezAno)==0
				nIntAno++
			Endif
		Else
			nIntAno++
		Endif
	Endif
	TRB->(DbSkip())
End

//================================
//Tabela 12 do SX5
//================================
//Códigos de 01 a 18 – Continente
//Códigos de 31 e 32 – Madeira
//Códigos de 41 a 49 – Açores
//================================

cQryReg:=" SELECT 'CONTINENTE' REGIAO,COUNT (*) QTD "
cQryReg+=" FROM "+RetSqlName("SX5")+" SX5 "
cQryReg+=" INNER JOIN "+RetSqlName("RCO")+" RCO ON "
cQryReg+=" X5_CHAVE=RCO_UF "
cQryReg+=" AND  RCO.D_E_L_E_T_='' "
cQryReg+=" WHERE X5_TABELA='12' "
cQryReg+=" AND X5_CHAVE >='01' AND X5_CHAVE <= '18' "
cQryReg+=" UNION "
cQryReg+=" SELECT 'MADEIRA' REGIAO,COUNT (*) QTD " 
cQryReg+=" FROM "+RetSqlName("SX5")+" SX5 "
cQryReg+=" INNER JOIN "+RetSqlName("RCO")+" RCO ON "
cQryReg+=" X5_CHAVE=RCO_UF "
cQryReg+=" AND  RCO.D_E_L_E_T_='' "
cQryReg+=" WHERE X5_TABELA='12' "
cQryReg+=" AND X5_CHAVE >='31' AND X5_CHAVE <= '32' "  
cQryReg+=" UNION "
cQryReg+=" SELECT 'ACORES' REGIAO,COUNT (*) QTD " 
cQryReg+=" FROM "+RetSqlName("SX5")+" SX5 "
cQryReg+=" INNER JOIN "+RetSqlName("RCO")+" RCO ON "
cQryReg+=" X5_CHAVE=RCO_UF "
cQryReg+=" AND  RCO.D_E_L_E_T_='' "
cQryReg+=" WHERE X5_TABELA='12' "
cQryReg+=" AND X5_CHAVE >='41' AND X5_CHAVE <= '49' "  

cQryReg := ChangeQuery(cQryReg)

If Select("TRBREG")>0
	DbSelectArea("TRBREG")
	TRBREG->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryReg),"TRBREG",.F.,.T.)
If TRBREG->(!Eof())
	Do While TRBREG->(!Eof())
		If UPPER(ALLTRIM(TRBREG->REGIAO))==UPPER(STR0015)//CONTINENTE
			nCon:= TRBREG->QTD
		ElseIf UPPER(ALLTRIM(TRBREG->REGIAO))==UPPER(STR0016)//MADEIRA 
			nMad:= TRBREG->QTD
		ElseIf UPPER(ALLTRIM(TRBREG->REGIAO))==UPPER(STR0017)//ACORES
			nAco:= TRBREG->QTD 
        Endif
		TRBREG->(Dbskip())
	End 
Endif
//6.3 - Numero Medio durante o Ano
nMedAno:=((nIntAno+nJanAno)/12)+((nIntAno+nFevAno)/12)+((nIntAno+nMarAno)/12)+((nIntAno+nAbrAno)/12)+((nIntAno+nMaiAno)/12)+((nIntAno+nJunAno)/12);
+((nIntAno+nJulAno)/12)+((nIntAno+nAgoAno)/12)+((nIntAno+nSetAno)/12)+((nIntAno+nOutAno)/12)+((nIntAno+nNovAno)/12)+((nIntAno+nDezAno)/12)

cQrYReg:=" SELECT RGQ_TIPITE,SUM(CT2_VALOR) CT2_VALOR "
cQrYReg+=" FROM "+RetSqlName("RGQ")+" RGQ "
cQrYReg+=" INNER JOIN "+RetSqlName("CT2")+" CT2 ON "
cQrYReg+=" RGQ_CODIGO=CT2_DEBITO "
cQrYReg+=" AND SUBSTRING(CT2_DATA,1,4)='"+cParAnoBas+"' "
cQrYReg+=" AND CT2.D_E_L_E_T_='' "
cQrYReg+=" WHERE RGQ.D_E_L_E_T_='' "
cQrYReg+=" AND RGQ_FILIAL IN ('"+cParFilial+"','"+space(FWGETTAMFILIAL)+"') "
cQrYReg+=" AND RGQ_ITEM='G' "
cQrYReg+=" GROUP BY RGQ_TIPITE "


cQrYReg := ChangeQuery(cQrYReg)

If Select("TRBREG2")>0
	DbSelectArea("TRBREG2")
	TRBREG2->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryReg),"TRBREG2",.F.,.T.)

DbSelectArea("TRBREG2")
TRBREG2->(dbGoTop()) 
If TRBREG2->(!Eof())         
	Do While TRBREG2->(!Eof())
		If TRBREG2->RGQ_TIPITE=="1" 	
		//8.1 - Custos com o pessoal
			nCusPes:=TRBREG2->CT2_VALOR
		ElseIf TRBREG2->RGQ_TIPITE=="2" 	
		//8.2 - Amortizacoes do Exercicio
			nAmoExe:=TRBREG2->CT2_VALOR		
		ElseIf TRBREG2->RGQ_TIPITE=="3" 	
		//8.3  - Provisoes do Exercicio
			nProExe:=TRBREG2->CT2_VALOR		
		ElseIf TRBREG2->RGQ_TIPITE=="4" 	
		//8.4  - Custos e perdas financeiras
			nCuPeFi:=TRBREG2->CT2_VALOR		
		ElseIf TRBREG2->RGQ_TIPITE=="5" 	
		//8.5  - Impostos sobre o rendimento
			nImpRen:=TRBREG2->CT2_VALOR		
		ElseIf TRBREG2->RGQ_TIPITE=="6"
		//8.6  - Resultado Liquido do Exercicio
			nResLiq:=TRBREG2->CT2_VALOR		
		Endif 	
		nVab+=TRBREG2->CT2_VALOR//8 - VAB	
		TRBREG2->(DbSkip())		
	End
Endif
//=====================================================
//LOG DA EMPRESA                                      
//=====================================================
aAdd( aLogProc, {"0",STR0018                ,"00"} )//IDENTIFICACAO DA EMPRESA   
aAdd( aLogProc, {"0",Replicate("*",130)     ,"01"} )
//Item 1
aAdd( aLogProc, {"0",STR0019+cNomEmp,"02"} )//"1 - Nome...........: "
//Item 2
aAdd( aLogProc, {"0",STR0020+cEndEmp,"03"} )//"2 - Morada.........: "
aAdd( aLogProc, {"0",STR0021+cBaiEmp,"04"} )//"2.1 - Localidade..........: "
aAdd( aLogProc, {"0",STR0022+cCepEmp,"05"} )//"2.2 - Cod.Postal..........: "
aAdd( aLogProc, {"0",STR0023+cTelEmp,"06"} )//"2.3 - Tel.................: "
aAdd( aLogProc, {"0",STR0024+cFaxEmp,"07"} )//"2.4 - Fax.................: "
aAdd( aLogProc, {"0",STR0025+cEstEmp,"08"} )//"2.5 - Distrito............: "
aAdd( aLogProc, {"0",STR0026+cCidEmp,"09"} )//"2.6 - Concelho............: "
//Item 3
aAdd( aLogProc, {"0",STR0028+cPesColJur,"11"} )//"3 - Numero de Pessoa Coletiva...........: "
//Item 4 - Atividade Principal da Empresa
aAdd( aLogProc, {"0",STR0029+cAtvEcoEmp,"12"} )//"4 - Atividade Principal da Empresa...........: "
//Item 5 - Numero de Estabelecimento
Aadd(aDadEmp,{"E","5.1"," "," ",""," "," ",nCon,0,0,0})//N Continente
Aadd(aDadEmp,{"E","5.2"," "," ",""," "," ",nAco,0,0,0})//N Acores
Aadd(aDadEmp,{"E","5.3"," "," ",""," "," ",nMad,0,0,0})//N Madeira 
aAdd( aLogProc, {"0",STR0030,"13"} )//"5 - Numero de Estabelecimento: "
aAdd( aLogProc, {"0",STR0031+Transform(nCon  ,"@E 999,999,999")+"   "+STR0032+Transform(nAco  ,"@E 999,999,999")+"   "+STR0033+Transform(nMad,"@E 999,999,999"),"14"} )//"5.1 - Num.Continente:  "#"   5.2 - Num.Acores.......: "#"   5.3 - Num.Madeira...: "
//Item 6 - Numero de Pessoas ao Servico
Aadd(aDadEmp,{"E","6.1"," "," ",""," "," ",n02Jan,0,0,0})//Em 2 de Janerio
Aadd(aDadEmp,{"E","6.2"," "," ",""," "," ",n31Dez,0,0,0})//Em 31 de Dezembro
Aadd(aDadEmp,{"E","6.3"," "," ",""," "," ",nMedAno,0,0,0})//Numero medio durante o ano
aAdd( aLogProc, {"0",STR0034,"15"} )//"6 - Numero de Pessoas ao Servico: "
aAdd( aLogProc, {"0",STR0035+Transform(n02Jan,"@E 999,999,999")+"   "+STR0036+Transform(n31Dez,"@E 999,999,999")+"   "+STR0037+Transform(nMedAno,"@E 999,999,999"),"16"} )//"6.1 - Em 2 de Janeiro: "#"   6.2 - Em 31 de Dezembro: "#"   6.3 - Num.Medio Ano:  "
//Item 7 - Natureza Juridica
Aadd(aDadEmp,{"E","7","",cNatJur,""," "," ",0,0,0,0})
aAdd( aLogProc, {"0",STR0038+cNatJur,"17"} )//"7 - Natureza juridica...........: "
//Item 8 - Valor Acrescentado Bruto(VAB)(em contos)                                 
Aadd(aDadEmp,{"E","8"  ," "," ",""," "," ",0,0,nVab   ,0})//VAB
Aadd(aDadEmp,{"E","8.1"," "," ",""," "," ",0,0,nCusPes,0})//Custos com o pessoal
Aadd(aDadEmp,{"E","8.2"," "," ",""," "," ",0,0,nAmoExe,0})//Amortizacoes do Exercicio
Aadd(aDadEmp,{"E","8.3"," "," ",""," "," ",0,0,nProExe,0})//Provisoes do Exercicio
Aadd(aDadEmp,{"E","8.4"," "," ",""," "," ",0,0,nCuPeFi,0})//Custos e perdas financeiras
Aadd(aDadEmp,{"E","8.5"," "," ",""," "," ",0,0,nImpRen,0})//Impostos sobre o rendimento
Aadd(aDadEmp,{"E","8.6"," "," ",""," "," ",0,0,nResLiq,0})//Resultado Liquido do Exercicio
aAdd( aLogProc, {"0",STR0039+Transform(nVab    ,"@E 999,999,999.99"),"18"} )//"8 - Valor Acrescentado Bruto: "         
aAdd( aLogProc, {"0",STR0040+Transform(nCusPes ,"@E 999,999,999.99"),"19"} )//"8.1 - Custos com o Pessoal...........: "
aAdd( aLogProc, {"0",STR0041+Transform(nAmoExe ,"@E 999,999,999.99"),"20"} )//"8.2 - Amortizacoes do Exercicio......: "
aAdd( aLogProc, {"0",STR0042+Transform(nProExe ,"@E 999,999,999.99"),"21"} )//"8.3 - Provisoes do Exercicio.........: "
aAdd( aLogProc, {"0",STR0043+Transform(nCuPeFi ,"@E 999,999,999.99"),"22"} )//"8.4 - Custos e Perdas Financeiras....: "
aAdd( aLogProc, {"0",STR0044+Transform(nImpRen ,"@E 999,999,999.99"),"23"} )//"8.5 - Imposto sobre Rendimento.......: "
aAdd( aLogProc, {"0",STR0045+Transform(nResLiq ,"@E 999,999,999.99"),"24"} )//"8.6 - Resultado Liquido do Exercicio.: "
aAdd( aLogProc, {"0",Replicate("=",130),"25"} )

MsgRun(STR0046,STR0047, {||GravaRGN(aDadEmp)})//Processando Dados da Empresa#Aguarde...

Return	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³EmpregoBS ³ Autor ³ Marcos Kato		      ³ Data ³   25.07.08    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processo da Geracao do Balanco Social de Portugal		         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Portugal                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³           ³											 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
	
Static Function EmpregoBS()
Local aEmpr1 := ARRAY(26,2,8)//Item e SubItem(Balanco Social),Sexo,Categoria
Local aEmpr2 := ARRAY(26,2,8)//Somente para o Item 1.2 - Numero Medio de pessoas durante o ano(Meses,Sexo,Categoria)
Local aEmpr3 := ARRAY(33,8)
Local aRepEfet:={},aNumMed:={},aFaixEta:={},aFuncAnt:={},aFuncEst:={},aFuncDef:={},aFuncNiv:={},aContTer:={},aMovSaid:={}
Local aPromoc:={},aReclass:={}
Local nSumIda:=0,nQtdPes:=0

Local nMedF11:=0,nMedF12:=0,nMedF13:=0,nMedF14:=0,nMedF15:=0,nMedF16:=0,nMedF17:=0,nMedF18:=0
Local nMedM11:=0,nMedM12:=0,nMedM13:=0,nMedM14:=0,nMedM15:=0,nMedM16:=0,nMedM17:=0,nMedM18:=0
Local nMedF2:=0,nMedF3:=0,nMedF4:=0,nMedF5:=0,nMedF6:=0,nMedF7:=0,nMedF8:=0
Local nMedM2:=0,nMedM3:=0,nMedM4:=0,nMedM5:=0,nMedM6:=0,nMedM7:=0,nMedM8:=0
//Sexo
Local nFem := 1//Feminino
Local nMas := 2//Masculino
//Categoria
Local nDir := 1//Dirigente
Local nQSup:= 2//Quadro Superior
Local nQMed:= 3//Quadro Medio
Local nQInt:= 4//Quadro Intermediario
Local nPAQ := 5//Profissionais altamente qualificados e qualificados
Local nPSQ := 6//Profissionais semiqualificados
Local nPNQ := 7//Profissionais nao qualificados
Local nPAp := 8//Praticantes\Aprendizes
local nCont1:=0,nCont2:=0,nCont:=0,nCont3:=0//Contador

For nCont1:=1 To 26
	For nCont2:=1 To 2
		For nCont3:=1 To 8
			aEmpr1[nCont1][nCont2][nCont3]	:=0
		Next
	Next
Next
For nCont1:=1 To 26
	For nCont2:=1 To 2
		For nCont3:=1 To 8
			aEmpr2[nCont1][nCont2][nCont3]	:=0
		Next
	Next
Next
For nCont1:=1 To 33
	For nCont2:=1 To 8
		aEmpr3[nCont1][nCont2]	:=0
	Next
Next

DbSelectArea("TRB")
TRB->(dbGoTop())

Do While TRB->(!Eof())
	nSexo := If( TRB->RA_SEXO=="F", nFem, nMas )
	If TRB->RGG_NIVEL=="1"
		nCateg:=nDir //Dirigente
	ElseIf TRB->RGG_NIVEL=="2"
		nCateg:=nQSup//Quadro Superior
	ElseIf TRB->RGG_NIVEL=="3"
		nCateg:=nQMed//Quadro Medio
	ElseIf TRB->RGG_NIVEL=="4"
		nCateg:=nQInt//Quadro Intermediario
	ElseIf TRB->RGG_NIVEL=="5"
		nCateg:=nPAQ //Profissionais altamente qualificados e qualificados
	ElseIf TRB->RGG_NIVEL=="6"
		nCateg:=nPSQ //Profissionais semiqualificados
	ElseIf TRB->RGG_NIVEL=="7"
		nCateg:=nPNQ //Profissionais nao qualificados
	ElseIf TRB->RGG_NIVEL=="8"
		nCateg:=nPAp //Praticantes\Aprendizes
	Else
		nCateg:=0
	Endif
	//====================================================================================================================================
	//EMPREGO
	//====================================================================================================================================
	If nCateg==0//caso o funcionario nao possua categoria o Bloco abaixo nao sera executado
		aAdd( aLogProc, {"9",Space(15)+STR0048+TRB->RA_MAT+STR0049,"1"+TRB->RA-MAT+"2"} )//"Funcionario "#" nao possui categoria informada"
	Else
		aEmpr1[1,nSexo,nCateg]++ //Posicao 1 ->Item 1.1 - Pessoas ao Serviço em 31 de Dezembro (Reparticao de efetivos)
		If TRB->TIPOCOBS=="1"
			aEmpr1[2,nSexo,nCateg]++ //Posicao 2 ->Item 1.1.1 - Com Contrato Permanente(Reparticao de efetivos)
			If nCateg<>1//Desconsiderar se o funcionario estiver na categoria de dirigente
				//Posicao 8 ->Item 1.9.3 - Contratados a Termo que passaram ao Q.Permanente(Contratos a Termo)
				nContHist:=0
				nContHist:=HistCont(TRB->RA_MAT,TRB->TIPOCOBS,"QP")
				aEmpr1[8,nSexo,nCateg]+=nContHist
				//Posicao 10-Item 1.10.1 - Saida de Pessoal com Contrato Permanente (Movimento de Saída)
				If !EMPTY(TRB->RA_DEMISSA) .And. TRB->RA_SITFOLH=="D"
					aEmpr1[10,nSexo,nCateg]++
				Endif
			Endif
		ElseIf TRB->TIPOCOBS=="2"
			aEmpr1[3,nSexo,nCateg]++ //Posicao 3 - Item 1.1.2 - Com Contrato a Termo Certo(Reparticao de efetivos)
			If nCateg<>1//Desconsiderar se o funcionario estiver na categoria de dirigente
				aEmpr1[6,nSexo,nCateg]++//Posicao 6 ->Item 1.9.1 - Com Contrato a Termo Certo(Contratos a Termo)
				//Posicao 9 ->Item 1.9.4 - Contratados a Termo que Transitaramdo ano anterior(Contratos a Termo)
				nContHist:=0
				nContHist:=HistCont(TRB->RA_MAT,TRB->TIPOCOBS,"AA")
				aEmpr1[9,nSexo,nCateg]+=nContHist
				//Posicao 11 ->Item 1.10.2 - Saida de Pessoal com Contrato Termo Certo e Incerto(Movimento de Saida)
				If !EMPTY(TRB->RA_DEMISSA) .And. TRB->RA_SITFOLH=="D"
					aEmpr1[11,nSexo,nCateg]++
				Endif
			Endif
		ElseIf TRB->TIPOCOBS=="3"
			aEmpr1[4,nSexo,nCateg]++ //Posicao 4 ->Item 1.1.3 - Com Contrato a Termo Incerto(Reparticao de efetivos)
			If nCateg<>1//Desconsiderar se o funcionario estiver na categoria de dirigente
				aEmpr1[7,nSexo,nCateg]++//Posicao 7 ->Item 1.9.2 - Com Contrato a Termo Incerto(Contratos a Termo)
				//Posicao 9->Item 1.9.4 - Contratados a Termo que Transitaram do ano anterior(Contratos a Termo)
				nContHist:=0
				nContHist:=HistCont(TRB->RA_MAT,TRB->TIPOCOBS,"AA")
				aEmpr1[9,nSexo,nCateg]+=nContHist
				//Posicao 11 - Item 1.10.2 - Saida de Pessoal com Contrato Termo Certo e Incerto(Movimento de Saida)Item 1.10.2 - Saida de Pessoal com Contrato Termo Certo e Incerto(Movimento de Saida)
				If !EMPTY(TRB->RA_DEMISSA) .And. TRB->RA_SITFOLH=="D"
					aEmpr1[11,nSexo,nCateg]++
				Endif
			Endif
		Else
			aEmpr1[5,nSexo,nCateg]++ //Posicao 5 ->Item 1.1.4 - Outros(Reparticao de efetivos)
			If nCateg<>1//Desconsiderar se o funcionario estiver na categoria de dirigente
				//Posicao 12->Item 1.10.3 - Saida de Outros Trabalhadores(Movimento de Saída)
				If !EMPTY(TRB->RA_DEMISSA) .And. TRB->RA_SITFOLH=="D"
					aEmpr1[12,nSexo,nCateg]++
				Endif
			Endif
		Endif
		
		If Empty(TRB->RA_DEMISSA) .Or.  (TRB->RA_DEMISSA >= cParAnoBas+"0101" .And. RA_DEMISSA <=cParAnoBas+"0131")
			//Item 1.2 - Numero Medio de pessoas durante o ano
			If EMPTY(TRB->RA_DEMISSA)
				aEmpr2[13,nSexo,nCateg]++
				//Item 1.9.5 - Numero Médio de contratados (Contratos a Termo)
				If TRB->TIPOCOBS$"2|3".And.nCateg<>1
					aEmpr2[26,nSexo,nCateg]++
				Endif
			ElseIf SUBSTR(TRB->RA_DEMISSA,5,2)<="01"//Janeiro
				aEmpr2[1,nSexo,nCateg]++
				//Item 1.9.5 - Numero Médio de contratados (Contratos a Termo)
				If TRB->TIPOCOBS$"2|3".And.nCateg<>1
					aEmpr2[14,nSexo,nCateg]++
				Endif
			ElseIf SUBSTR(TRB->RA_DEMISSA,5,2)<="02"//Fevereiro
				aEmpr2[2,nSexo,nCateg]++
				//Item 1.9.5 - Numero Médio de contratados (Contratos a Termo)
				If TRB->TIPOCOBS$"2|3".And.nCateg<>1
					aEmpr2[15,nSexo,nCateg]++
				Endif
			ElseIf SUBSTR(TRB->RA_DEMISSA,5,2)<="03"//Marco
				aEmpr2[3,nSexo,nCateg]++
				//Item 1.9.5 - Numero Médio de contratados (Contratos a Termo)
				If TRB->TIPOCOBS$"2|3".And.nCateg<>1
					aEmpr2[16,nSexo,nCateg]++
				Endif
			ElseIf SUBSTR(TRB->RA_DEMISSA,5,2)<="04"//Abril
				aEmpr2[4,nSexo,nCateg]++
				//Item 1.9.5 - Numero Médio de contratados (Contratos a Termo)
				If TRB->TIPOCOBS$"2|3".And.nCateg<>1
					aEmpr2[17,nSexo,nCateg]++
				Endif
			ElseIf SUBSTR(TRB->RA_DEMISSA,5,2)<="05"//Maio
				aEmpr2[5,nSexo,nCateg]++
				//Item 1.9.5 - Numero Médio de contratados (Contratos a Termo)
				If TRB->TIPOCOBS$"2|3".And.nCateg<>1
					aEmpr2[18,nSexo,nCateg]++
				Endif
			ElseIf SUBSTR(TRB->RA_DEMISSA,5,2)<="06"//Junho
				aEmpr2[6,nSexo,nCateg]++
				//Item 1.9.5 - Numero Médio de contratados (Contratos a Termo)
				If TRB->TIPOCOBS$"2|3".And.nCateg<>1
					aEmpr2[19,nSexo,nCateg]++
				Endif
			ElseIf SUBSTR(TRB->RA_DEMISSA,5,2)<="07"//Julho
				aEmpr2[7,nSexo,nCateg]++
				//Item 1.9.5 - Numero Médio de contratados (Contratos a Termo)
				If TRB->TIPOCOBS$"2|3".And.nCateg<>1
					aEmpr2[20,nSexo,nCateg]++
				Endif
			ElseIf SUBSTR(TRB->RA_DEMISSA,5,2)<="08"//Agosto
				aEmpr2[8,nSexo,nCateg]++
				//Item 1.9.5 - Numero Médio de contratados (Contratos a Termo)
				If TRB->TIPOCOBS$"2|3".And.nCateg<>1
					aEmpr2[21,nSexo,nCateg]++
				Endif
			ElseIf SUBSTR(TRB->RA_DEMISSA,5,2)<="09"//Setembro
				aEmpr2[9,nSexo,nCateg]++
				//Item 1.9.5 - Numero Médio de contratados (Contratos a Termo)
				If TRB->TIPOCOBS$"2|3".And.nCateg<>1
					aEmpr2[22,nSexo,nCateg]++
				Endif
			ElseIf SUBSTR(TRB->RA_DEMISSA,5,2)<="10"//Outubro
				aEmpr2[10,nSexo,nCateg]++
				//Item 1.9.5 - Numero Médio de contratados (Contratos a Termo)
				If TRB->TIPOCOBS$"2|3".And.nCateg<>1
					aEmpr2[23,nSexo,nCateg]++
				Endif
			ElseIf SUBSTR(TRB->RA_DEMISSA,5,2)<="11"//Novembro
				aEmpr2[11,nSexo,nCateg]++
				//Item 1.9.5 - Numero Médio de contratados (Contratos a Termo)
				If TRB->TIPOCOBS$"2|3".And.nCateg<>1
					aEmpr2[24,nSexo,nCateg]++
				Endif
			Else//Dezembro
				aEmpr2[12,nSexo,nCateg]++
				//Item 1.9.5 - Numero Médio de contratados (Contratos a Termo)
				If TRB->TIPOCOBS$"2|3".And.nCateg<>1
					aEmpr2[25,nSexo,nCateg]++
				Endif
			Endif		

			//Item 1.3 - Estrutura Etaria
			If DateDiffYear(stod(TRB->RA_NASC),dDatabase ) <= 15
				nSumIda+=DateDiffYear(stod(TRB->RA_NASC),dDatabase )
				nQtdPes++
				aEmpr3[1,nSexo]++
			ElseIf DateDiffYear(stod(TRB->RA_NASC),dDatabase ) <= 17
				nSumIda+=DateDiffYear(stod(TRB->RA_NASC),dDatabase )
				nQtdPes++
				aEmpr3[2,nSexo]++
			ElseIf DateDiffYear(stod(TRB->RA_NASC),dDatabase ) <= 24
				nSumIda+=DateDiffYear(stod(TRB->RA_NASC),dDatabase )
				nQtdPes++
				aEmpr3[3,nSexo]++
			ElseIf DateDiffYear(stod(TRB->RA_NASC),dDatabase ) <= 29
				nSumIda+=DateDiffYear(stod(TRB->RA_NASC),dDatabase )
				nQtdPes++
				aEmpr3[4,nSexo]++
			ElseIf DateDiffYear(stod(TRB->RA_NASC),dDatabase ) <= 34
				nSumIda+=DateDiffYear(stod(TRB->RA_NASC),dDatabase )
				nQtdPes++
				aEmpr3[5,nSexo]++
			ElseIf DateDiffYear(stod(TRB->RA_NASC),dDatabase ) <= 39
				nSumIda+=DateDiffYear(stod(TRB->RA_NASC),dDatabase )
				nQtdPes++
				aEmpr3[6,nSexo]++
			ElseIf DateDiffYear(stod(TRB->RA_NASC),dDatabase ) <= 44
				nSumIda+=DateDiffYear(stod(TRB->RA_NASC),dDatabase )
				nQtdPes++
				aEmpr3[7,nSexo]++
			ElseIf DateDiffYear(stod(TRB->RA_NASC),dDatabase ) <= 49
				nSumIda+=DateDiffYear(stod(TRB->RA_NASC),dDatabase )
				nQtdPes++
				aEmpr3[8,nSexo]++
			ElseIf DateDiffYear(stod(TRB->RA_NASC),dDatabase ) <= 54
				nSumIda+=DateDiffYear(stod(TRB->RA_NASC),dDatabase )
				nQtdPes++
				aEmpr3[9,nSexo]++
			ElseIf DateDiffYear(stod(TRB->RA_NASC),dDatabase ) <= 59
				nSumIda+=DateDiffYear(stod(TRB->RA_NASC),dDatabase )
				nQtdPes++
				aEmpr3[10,nSexo]++
			ElseIf DateDiffYear(stod(TRB->RA_NASC),dDatabase ) <= 61
				nSumIda+=DateDiffYear(stod(TRB->RA_NASC),dDatabase )
				nQtdPes++
				aEmpr3[11,nSexo]++
			ElseIf DateDiffYear(stod(TRB->RA_NASC),dDatabase ) <= 64
				nSumIda+=DateDiffYear(stod(TRB->RA_NASC),dDatabase )
				nQtdPes++
				aEmpr3[12,nSexo]++
			Else
				nSumIda+=DateDiffYear(stod(TRB->RA_NASC),dDatabase )
				nQtdPes++
				aEmpr3[13,nSexo,nCateg]++
			Endif
			//Item 1.5- Antiguidade
			If DateDiffYear(stod(TRB->RA_ADMISSA),dDatabase ) <= 1
				aEmpr3[14,nSexo]++//Ate 1 Ano
			ElseIf DateDiffYear(stod(TRB->RA_ADMISSA),dDatabase ) <= 2
				aEmpr3[15,nSexo]++//Mais de 1 ate 2 Anos
			ElseIf DateDiffYear(stod(TRB->RA_ADMISSA),dDatabase ) <= 5
				aEmpr3[16,nSexo]++//Mais de 2 ate 5 Anos
			ElseIf DateDiffYear(stod(TRB->RA_ADMISSA),dDatabase ) <= 10
				aEmpr3[17,nSexo]++//Mais de 5 ate 10 Anos
			ElseIf DateDiffYear(stod(TRB->RA_ADMISSA),dDatabase ) <= 15
				aEmpr3[18,nSexo]++//Mais de 10 ate 15 Anos
			Else
				aEmpr3[19,nSexo]++//Mais de 15 Anos
			Endif
			//Item 1.6 - Estrangeiros
			If Empty(TRB->RA_CPAISOR)//Caso o campo nao esteja preenchido sera considerado como Outros Paises
				aAdd( aLogProc, {"9",Space(15)+STR0050+TRB->RA_MAT+STR0051,"3"+TRB->RA_MAT+"2"} )//"Nacionalidade origem do Funcionario "#" nao informado "
			Else
				DbSelectArea("RCC")
				RCC->(DbSetOrder(1))
				RCC->(DbGoTop())
				If DbSeek(cParFilial+"S024")
					Do While !Eof()
						If TRB->RA_CPAISOR==Substr(RCC_CONTEU,1,2)
							If Substr(RCC_CONTEU,33,2)=="01"//Paises da Uniao Europeia
								aEmpr3[20,nSexo]++
							ElseIf Substr(RCC_CONTEU,33,2)=="02"//paises africanos da lingua oficial portuguesa
								aEmpr3[21,nSexo]++
							ElseIf Substr(RCC_CONTEU,33,2)=="03"//Brasil
								aEmpr3[22,nSexo]++
							Else// Outros Paises
								aEmpr3[23,nSexo]++
							Endif
							Exit
						Endif
						RCC->(DbSkip())
					End
				Endif
			Endif
			//Deficiente Fisicos for conter "2" ou "3"(2 - Deficiente / 3 - Deficiente Forcas Armadas) ou
			//Tipo de Deficiência diferente de "0" (0 - Não eh deficiente)
			If  (TRB->RA_DEFIFIS $ "2*3".Or.TRB->RA_TPDEFFI != "0")
				aEmpr3[24,nSexo]++
			Endif
			//Item 1.8 - Niveis de Habilitacao ou Grau de Instrucao
			If Empty(TRB->RA_GRINRAI)//Caso o campo esteja vazio sera considerado como Outros
				aAdd( aLogProc, {"9",Space(15)+STR0048+TRB->RA_MAT+STR0052,"2"+TRB->RA_MAT+"2"} )//"Funcionario "#" nao possui grau de instrucao informado"
			ElseIf TRB->RA_GRINRAI=="01"//Inferior ao 1 ciclo do ensino basico
				aEmpr3[25,nSexo]++
			ElseIf TRB->RA_GRINRAI=="02"//1 Ciclo de ensino basico
				aEmpr3[26,nSexo]++
			ElseIf TRB->RA_GRINRAI=="03"//2 Ciclo de ensino basico
				aEmpr3[27,nSexo]++
			ElseIf TRB->RA_GRINRAI=="04"//3 Ciclo de ensino basico
				aEmpr3[28,nSexo]++
			ElseIf TRB->RA_GRINRAI=="05"//Ensino Secundario
				aEmpr3[29,nSexo]++
			ElseIf TRB->RA_GRINRAI=="06"//Ensino Superior de indole Profissional
				aEmpr3[30,nSexo]++
			ElseIf TRB->RA_GRINRAI=="07"//Ensino Superior Politecnico
				aEmpr3[31,nSexo]++
			ElseIf TRB->RA_GRINRAI=="08"//Ensino superior Universitario
				aEmpr3[32,nSexo]++
			Else//09 - Outros
				aEmpr3[33,nSexo]++
			Endif
		Endif
		//Item 1.16 - Numero Trabalhadores(Reconversoes)
		//RGH->Historico de Alteracoes de Categoria
		DbSelectArea("RGH")
		RGH->(DbSetOrder(3))//Ordem: RGH_FILIAL+RGH_MAT+RGH_DTINIC
		RGH->(dbGoTop())
		If DbSeek(cParFilial+TRB->RA_MAT)
			If Substr(Dtos(RGH->RGH_DTINIC),1,4)==cParAnoBas
				If TRB->RGG_NIVEL=="2"
					aEmpr1[16,nSexo,nCateg]++
				ElseIf TRB->RGG_NIVEL=="3"
					aEmpr1[16,nSexo,nCateg]++
				ElseIf TRB->RGG_NIVEL=="4"
					aEmpr1[16,nSexo,nCateg]++
				ElseIf TRB->RGG_NIVEL=="5"
					aEmpr1[16,nSexo,nCateg]++
				ElseIf TRB->RGG_NIVEL=="6"
					aEmpr1[16,nSexo,nCateg]++
				ElseIf TRB->RGG_NIVEL=="7"
					aEmpr1[16,nSexo,nCateg]++
				ElseIf TRB->RGG_NIVEL=="8"
					aEmpr1[16,nSexo,nCateg]++
				Endif
			Endif
		Endif
	Endif
	
	If TRB->RA_TIPOALT=="004"//Item 1.15.1 -  Antiguidade
		aEmpr1[13,nSexo,nCateg]++
	ElseIf TRB->RA_TIPOALT=="004"//Item 1.15.2 - Merito
		aEmpr1[14,nSexo,nCateg]++
	Else//Item 1.15.3 - Outras
		aEmpr1[15,nSexo,nCateg]++
	Endif
	TRB->(DbSkip())
End	
//Item 1.2 - Numero Medio de pessoas durante o ano
nMedF11:=((aEmpr2[1,1,1]+aEmpr2[2,1,1]+aEmpr2[3,1,1]+aEmpr2[4,1,1]+aEmpr2[5,1,1]+aEmpr2[6,1,1]+aEmpr2[7,1,1]+aEmpr2[8,1,1]+aEmpr2[9,1,1]+aEmpr2[10,1,1]+aEmpr2[11,1,1]+aEmpr2[12,1,1])/12)+aEmpr2[13,1,1]
nMedM11:=((aEmpr2[1,2,1]+aEmpr2[2,2,1]+aEmpr2[3,2,1]+aEmpr2[4,2,1]+aEmpr2[5,2,1]+aEmpr2[6,2,1]+aEmpr2[7,2,1]+aEmpr2[8,2,1]+aEmpr2[9,2,1]+aEmpr2[10,2,1]+aEmpr2[11,2,1]+aEmpr2[12,2,1])/12)+aEmpr2[13,1,1]
nMedF12:=((aEmpr2[1,1,2]+aEmpr2[2,1,2]+aEmpr2[3,1,2]+aEmpr2[4,1,2]+aEmpr2[5,1,2]+aEmpr2[6,1,2]+aEmpr2[7,1,2]+aEmpr2[8,1,2]+aEmpr2[9,1,2]+aEmpr2[10,1,2]+aEmpr2[11,1,2]+aEmpr2[12,1,2])/12)+aEmpr2[13,1,2]
nMedM12:=((aEmpr2[1,2,2]+aEmpr2[2,2,2]+aEmpr2[3,2,2]+aEmpr2[4,2,2]+aEmpr2[5,2,2]+aEmpr2[6,2,2]+aEmpr2[7,2,2]+aEmpr2[8,2,2]+aEmpr2[9,2,2]+aEmpr2[10,2,2]+aEmpr2[11,2,2]+aEmpr2[12,2,2])/12)+aEmpr2[13,2,2]
nMedF13:=((aEmpr2[1,1,3]+aEmpr2[2,1,3]+aEmpr2[3,1,3]+aEmpr2[4,1,3]+aEmpr2[5,1,3]+aEmpr2[6,1,3]+aEmpr2[7,1,3]+aEmpr2[8,1,3]+aEmpr2[9,1,3]+aEmpr2[10,1,3]+aEmpr2[11,1,3]+aEmpr2[12,1,3])/12)+aEmpr2[13,1,3]
nMedM13:=((aEmpr2[1,2,3]+aEmpr2[2,2,3]+aEmpr2[3,2,3]+aEmpr2[4,2,3]+aEmpr2[5,2,3]+aEmpr2[6,2,3]+aEmpr2[7,2,3]+aEmpr2[8,2,3]+aEmpr2[9,2,3]+aEmpr2[10,2,3]+aEmpr2[11,2,3]+aEmpr2[12,2,3])/12)+aEmpr2[13,2,3]
nMedF14:=((aEmpr2[1,1,4]+aEmpr2[2,1,4]+aEmpr2[3,1,4]+aEmpr2[4,1,4]+aEmpr2[5,1,4]+aEmpr2[6,1,4]+aEmpr2[7,1,4]+aEmpr2[8,1,4]+aEmpr2[9,1,4]+aEmpr2[10,1,4]+aEmpr2[11,1,4]+aEmpr2[12,1,4])/12)+aEmpr2[13,1,4]
nMedM14:=((aEmpr2[1,2,4]+aEmpr2[2,2,4]+aEmpr2[3,2,4]+aEmpr2[4,2,4]+aEmpr2[5,2,4]+aEmpr2[6,2,4]+aEmpr2[7,2,4]+aEmpr2[8,2,4]+aEmpr2[9,2,4]+aEmpr2[10,2,4]+aEmpr2[11,2,4]+aEmpr2[12,2,4])/12)+aEmpr2[13,2,4]
nMedF15:=((aEmpr2[1,1,5]+aEmpr2[2,1,5]+aEmpr2[3,1,5]+aEmpr2[4,1,5]+aEmpr2[5,1,5]+aEmpr2[6,1,5]+aEmpr2[7,1,5]+aEmpr2[8,1,5]+aEmpr2[9,1,5]+aEmpr2[10,1,5]+aEmpr2[11,1,5]+aEmpr2[12,1,5])/12)+aEmpr2[13,1,5]
nMedM15:=((aEmpr2[1,2,5]+aEmpr2[2,2,5]+aEmpr2[3,2,5]+aEmpr2[4,2,5]+aEmpr2[5,2,5]+aEmpr2[6,2,5]+aEmpr2[7,2,5]+aEmpr2[8,2,5]+aEmpr2[9,2,5]+aEmpr2[10,2,5]+aEmpr2[11,2,5]+aEmpr2[12,2,5])/12)+aEmpr2[13,2,5]
nMedF16:=((aEmpr2[1,1,6]+aEmpr2[2,1,6]+aEmpr2[3,1,6]+aEmpr2[4,1,6]+aEmpr2[5,1,6]+aEmpr2[6,1,6]+aEmpr2[7,1,6]+aEmpr2[8,1,6]+aEmpr2[9,1,6]+aEmpr2[10,1,6]+aEmpr2[11,1,6]+aEmpr2[12,1,6])/12)+aEmpr2[13,1,6]
nMedM16:=((aEmpr2[1,2,6]+aEmpr2[2,2,6]+aEmpr2[3,2,6]+aEmpr2[4,2,6]+aEmpr2[5,2,6]+aEmpr2[6,2,6]+aEmpr2[7,2,6]+aEmpr2[8,2,6]+aEmpr2[9,2,6]+aEmpr2[10,2,6]+aEmpr2[11,2,6]+aEmpr2[12,2,6])/12)+aEmpr2[13,2,6]
nMedF17:=((aEmpr2[1,1,7]+aEmpr2[2,1,7]+aEmpr2[3,1,7]+aEmpr2[4,1,7]+aEmpr2[5,1,7]+aEmpr2[6,1,7]+aEmpr2[7,1,7]+aEmpr2[8,1,7]+aEmpr2[9,1,7]+aEmpr2[10,1,7]+aEmpr2[11,1,7]+aEmpr2[12,1,7])/12)+aEmpr2[13,1,7]
nMedM17:=((aEmpr2[1,2,7]+aEmpr2[2,2,7]+aEmpr2[3,2,7]+aEmpr2[4,2,7]+aEmpr2[5,2,7]+aEmpr2[6,2,7]+aEmpr2[7,2,7]+aEmpr2[8,2,7]+aEmpr2[9,2,7]+aEmpr2[10,2,7]+aEmpr2[11,2,7]+aEmpr2[12,2,7])/12)+aEmpr2[13,2,7]
nMedF18:=((aEmpr2[1,1,8]+aEmpr2[2,1,8]+aEmpr2[3,1,8]+aEmpr2[4,1,8]+aEmpr2[5,1,8]+aEmpr2[6,1,8]+aEmpr2[7,1,8]+aEmpr2[8,1,8]+aEmpr2[9,1,8]+aEmpr2[10,1,8]+aEmpr2[11,1,8]+aEmpr2[12,1,8])/12)+aEmpr2[13,1,8]
nMedM18:=((aEmpr2[1,2,8]+aEmpr2[2,2,8]+aEmpr2[3,2,8]+aEmpr2[4,2,8]+aEmpr2[5,2,8]+aEmpr2[6,2,8]+aEmpr2[7,2,8]+aEmpr2[8,2,8]+aEmpr2[9,2,8]+aEmpr2[10,2,8]+aEmpr2[11,2,8]+aEmpr2[12,2,8])/12)+aEmpr2[13,2,8]
//Item 1.9.5 - Numero Medio de contratados (Contratos a Termo)
nMedF2:=((aEmpr2[14,1,2]+aEmpr2[15,1,2]+aEmpr2[16,1,2]+aEmpr2[17,1,2]+aEmpr2[18,1,2]+aEmpr2[19,1,2]+aEmpr2[20,1,2]+aEmpr2[21,1,2]+aEmpr2[22,1,2]+aEmpr2[23,1,2]+aEmpr2[24,1,2]+aEmpr2[25,1,2])/12)+aEmpr2[26,1,2]
nMedM2:=((aEmpr2[14,2,2]+aEmpr2[15,2,2]+aEmpr2[16,2,2]+aEmpr2[17,2,2]+aEmpr2[18,2,2]+aEmpr2[19,2,2]+aEmpr2[20,2,2]+aEmpr2[21,2,2]+aEmpr2[22,2,2]+aEmpr2[23,2,2]+aEmpr2[24,2,2]+aEmpr2[25,2,2])/12)+aEmpr2[26,2,2]
nMedF3:=((aEmpr2[14,1,3]+aEmpr2[15,1,3]+aEmpr2[16,1,3]+aEmpr2[17,1,3]+aEmpr2[18,1,3]+aEmpr2[19,1,3]+aEmpr2[20,1,3]+aEmpr2[21,1,3]+aEmpr2[22,1,3]+aEmpr2[23,1,3]+aEmpr2[24,1,3]+aEmpr2[25,1,3])/12)+aEmpr2[26,1,3]
nMedM3:=((aEmpr2[14,2,3]+aEmpr2[15,2,3]+aEmpr2[16,2,3]+aEmpr2[17,2,3]+aEmpr2[18,2,3]+aEmpr2[19,2,3]+aEmpr2[20,2,3]+aEmpr2[21,2,3]+aEmpr2[22,2,3]+aEmpr2[23,2,3]+aEmpr2[24,2,3]+aEmpr2[25,2,3])/12)+aEmpr2[26,2,3]
nMedF4:=((aEmpr2[14,1,4]+aEmpr2[15,1,4]+aEmpr2[16,1,4]+aEmpr2[17,1,4]+aEmpr2[18,1,4]+aEmpr2[19,1,4]+aEmpr2[20,1,4]+aEmpr2[21,1,4]+aEmpr2[22,1,4]+aEmpr2[23,1,4]+aEmpr2[24,1,4]+aEmpr2[25,1,4])/12)+aEmpr2[26,1,4]
nMedM4:=((aEmpr2[14,2,4]+aEmpr2[15,2,4]+aEmpr2[16,2,4]+aEmpr2[17,2,4]+aEmpr2[18,2,4]+aEmpr2[19,2,4]+aEmpr2[20,2,4]+aEmpr2[21,2,4]+aEmpr2[22,2,4]+aEmpr2[23,2,4]+aEmpr2[24,2,4]+aEmpr2[25,2,4])/12)+aEmpr2[26,2,4]
nMedF5:=((aEmpr2[14,1,5]+aEmpr2[15,1,5]+aEmpr2[16,1,5]+aEmpr2[17,1,5]+aEmpr2[18,1,5]+aEmpr2[19,1,5]+aEmpr2[20,1,5]+aEmpr2[21,1,5]+aEmpr2[22,1,5]+aEmpr2[23,1,5]+aEmpr2[24,1,5]+aEmpr2[25,1,5])/12)+aEmpr2[26,1,5]
nMedM5:=((aEmpr2[14,2,5]+aEmpr2[15,2,5]+aEmpr2[16,2,5]+aEmpr2[17,2,5]+aEmpr2[18,2,5]+aEmpr2[19,2,5]+aEmpr2[20,2,5]+aEmpr2[21,2,5]+aEmpr2[22,2,5]+aEmpr2[23,2,5]+aEmpr2[24,2,5]+aEmpr2[25,2,5])/12)+aEmpr2[26,2,5]
nMedF6:=((aEmpr2[14,1,6]+aEmpr2[15,1,6]+aEmpr2[16,1,6]+aEmpr2[17,1,6]+aEmpr2[18,1,6]+aEmpr2[19,1,6]+aEmpr2[20,1,6]+aEmpr2[21,1,6]+aEmpr2[22,1,6]+aEmpr2[23,1,6]+aEmpr2[24,1,6]+aEmpr2[25,1,6])/12)+aEmpr2[26,1,6]
nMedM6:=((aEmpr2[14,2,6]+aEmpr2[15,2,6]+aEmpr2[16,2,6]+aEmpr2[17,2,6]+aEmpr2[18,2,6]+aEmpr2[19,2,6]+aEmpr2[20,2,6]+aEmpr2[21,2,6]+aEmpr2[22,2,6]+aEmpr2[23,2,6]+aEmpr2[24,2,6]+aEmpr2[25,2,6])/12)+aEmpr2[26,2,6]
nMedF7:=((aEmpr2[14,1,7]+aEmpr2[15,1,7]+aEmpr2[16,1,7]+aEmpr2[17,1,7]+aEmpr2[18,1,7]+aEmpr2[19,1,7]+aEmpr2[20,1,7]+aEmpr2[21,1,7]+aEmpr2[22,1,7]+aEmpr2[23,1,7]+aEmpr2[24,1,7]+aEmpr2[25,1,7])/12)+aEmpr2[26,1,7]
nMedM7:=((aEmpr2[14,2,7]+aEmpr2[15,2,7]+aEmpr2[16,2,7]+aEmpr2[17,2,7]+aEmpr2[18,2,7]+aEmpr2[19,2,7]+aEmpr2[20,2,7]+aEmpr2[21,2,7]+aEmpr2[22,2,7]+aEmpr2[23,2,7]+aEmpr2[24,2,7]+aEmpr2[25,2,7])/12)+aEmpr2[26,2,7]
nMedF8:=((aEmpr2[14,1,8]+aEmpr2[15,1,8]+aEmpr2[16,1,8]+aEmpr2[17,1,8]+aEmpr2[18,1,8]+aEmpr2[19,1,8]+aEmpr2[20,1,8]+aEmpr2[21,1,8]+aEmpr2[22,1,8]+aEmpr2[23,1,8]+aEmpr2[24,1,8]+aEmpr2[25,1,8])/12)+aEmpr2[26,1,8]
nMedM8:=((aEmpr2[14,2,8]+aEmpr2[15,2,8]+aEmpr2[16,2,8]+aEmpr2[17,2,8]+aEmpr2[18,2,8]+aEmpr2[19,2,8]+aEmpr2[20,2,8]+aEmpr2[21,2,8]+aEmpr2[22,2,8]+aEmpr2[23,2,8]+aEmpr2[24,2,8]+aEmpr2[25,2,8])/12)+aEmpr2[26,2,8]
//================================================================================================
//Gravando os dados na tabela do Balanco Social
//================================================================================================
//Item 1.1 - Pessoas ao Serviço em 31 de Dezembro (Reparticao de efetivos)
Aadd(aRepEfet,{"F","1.01","0101"," "," "," "," ",aEmpr1[1,2,1],aEmpr1[1,1,1],0,0})//Dirigentes
Aadd(aRepEfet,{"F","1.01","0102"," "," "," "," ",aEmpr1[1,2,2],aEmpr1[1,1,2],0,0})//Quadro Superiores
Aadd(aRepEfet,{"F","1.01","0103"," "," "," "," ",aEmpr1[1,2,3],aEmpr1[1,1,3],0,0})//Quadro Medios
Aadd(aRepEfet,{"F","1.01","0104"," "," "," "," ",aEmpr1[1,2,4],aEmpr1[1,1,4],0,0})//Quadro Intermediarios
Aadd(aRepEfet,{"F","1.01","0105"," "," "," "," ",aEmpr1[1,2,5],aEmpr1[1,1,5],0,0})//Profissionais altamente qualificados e qualificados
Aadd(aRepEfet,{"F","1.01","0106"," "," "," "," ",aEmpr1[1,2,6],aEmpr1[1,1,6],0,0})//Profissionais semiqualificados
Aadd(aRepEfet,{"F","1.01","0107"," "," "," "," ",aEmpr1[1,2,7],aEmpr1[1,1,7],0,0})//Profissionais nao qualificados
Aadd(aRepEfet,{"F","1.01","0108"," "," "," "," ",aEmpr1[1,2,8],aEmpr1[1,1,8],0,0})//Praticantes\Aprendizes
//Item 1.1.1 - Com Contrato Permanente(Reparticao de efetivos)
Aadd(aRepEfet,{"F","1.01.1","0101"," "," "," "," ",aEmpr1[2,2,1],aEmpr1[2,1,1],0,0})//Dirigentes
Aadd(aRepEfet,{"F","1.01.1","0102"," "," "," "," ",aEmpr1[2,2,2],aEmpr1[2,1,2],0,0})//Quadro Superiores
Aadd(aRepEfet,{"F","1.01.1","0103"," "," "," "," ",aEmpr1[2,2,3],aEmpr1[2,1,3],0,0})//Quadro Medios
Aadd(aRepEfet,{"F","1.01.1","0104"," "," "," "," ",aEmpr1[2,2,4],aEmpr1[2,1,4],0,0})//Quadro Intermediarios
Aadd(aRepEfet,{"F","1.01.1","0105"," "," "," "," ",aEmpr1[2,2,5],aEmpr1[2,1,5],0,0})//Profissionais altamente qualificados e qualificados
Aadd(aRepEfet,{"F","1.01.1","0106"," "," "," "," ",aEmpr1[2,2,6],aEmpr1[2,1,6],0,0})//Profissionais semiqualificados
Aadd(aRepEfet,{"F","1.01.1","0107"," "," "," "," ",aEmpr1[2,2,7],aEmpr1[2,1,7],0,0})//Profissionais nao qualificados
Aadd(aRepEfet,{"F","1.01.1","0108"," "," "," "," ",aEmpr1[2,2,8],aEmpr1[2,1,8],0,0})//Praticantes\Aprendizes
//Item 1.1.2 - Com Contrato a Termo Certo(Reparticao de efetivos)
Aadd(aRepEfet,{"F","1.01.2","0101"," "," "," "," ",aEmpr1[3,2,1],aEmpr1[3,1,1],0,0})//Dirigentes
Aadd(aRepEfet,{"F","1.01.2","0102"," "," "," "," ",aEmpr1[3,2,2],aEmpr1[3,1,2],0,0})//Quadro Superiores
Aadd(aRepEfet,{"F","1.01.2","0103"," "," "," "," ",aEmpr1[3,2,3],aEmpr1[3,1,3],0,0})//Quadro Medios
Aadd(aRepEfet,{"F","1.01.2","0104"," "," "," "," ",aEmpr1[3,2,4],aEmpr1[3,1,4],0,0})//Quadro Intermediarios
Aadd(aRepEfet,{"F","1.01.2","0105"," "," "," "," ",aEmpr1[3,2,5],aEmpr1[3,1,5],0,0})//Profissionais altamente qualificados e qualificados
Aadd(aRepEfet,{"F","1.01.2","0106"," "," "," "," ",aEmpr1[3,2,6],aEmpr1[3,1,6],0,0})//Profissionais semiqualificados
Aadd(aRepEfet,{"F","1.01.2","0107"," "," "," "," ",aEmpr1[3,2,7],aEmpr1[3,1,7],0,0})//Profissionais nao qualificados
Aadd(aRepEfet,{"F","1.01.2","0108"," "," "," "," ",aEmpr1[3,2,8],aEmpr1[3,1,8],0,0})//Praticantes\Aprendizes
//Item 1.1.3 - Com Contrato a Termo Incerto(Reparticao de efetivos)
Aadd(aRepEfet,{"F","1.01.3","0101"," "," "," "," ",aEmpr1[4,2,1],aEmpr1[4,1,1],0,0})//Dirigentes
Aadd(aRepEfet,{"F","1.01.3","0102"," "," "," "," ",aEmpr1[4,2,2],aEmpr1[4,1,2],0,0})//Quadro Superiores
Aadd(aRepEfet,{"F","1.01.3","0103"," "," "," "," ",aEmpr1[4,2,3],aEmpr1[4,1,3],0,0})//Quadro Medios
Aadd(aRepEfet,{"F","1.01.3","0104"," "," "," "," ",aEmpr1[4,2,4],aEmpr1[4,1,4],0,0})//Quadro Intermediarios
Aadd(aRepEfet,{"F","1.01.3","0105"," "," "," "," ",aEmpr1[4,2,5],aEmpr1[4,1,5],0,0})//Profissionais altamente qualificados e qualificados
Aadd(aRepEfet,{"F","1.01.3","0106"," "," "," "," ",aEmpr1[4,2,6],aEmpr1[4,1,6],0,0})//Profissionais semiqualificados
Aadd(aRepEfet,{"F","1.01.3","0107"," "," "," "," ",aEmpr1[4,2,7],aEmpr1[4,1,7],0,0})//Profissionais nao qualificados
Aadd(aRepEfet,{"F","1.01.3","0108"," "," "," "," ",aEmpr1[4,2,8],aEmpr1[4,1,8],0,0})//Praticantes\Aprendizes
//Item 1.1.4 - Outros(Reparticao de efetivos)
Aadd(aRepEfet,{"F","1.01.4","0101"," "," "," "," ",aEmpr1[5,2,1],aEmpr1[5,1,1],0,0})//Dirigentes
Aadd(aRepEfet,{"F","1.01.4","0102"," "," "," "," ",aEmpr1[5,2,2],aEmpr1[5,1,2],0,0})//Quadro Superiores
Aadd(aRepEfet,{"F","1.01.4","0103"," "," "," "," ",aEmpr1[5,2,3],aEmpr1[5,1,3],0,0})//Quadro Medios
Aadd(aRepEfet,{"F","1.01.4","0104"," "," "," "," ",aEmpr1[5,2,4],aEmpr1[5,1,4],0,0})//Quadro Intermediarios
Aadd(aRepEfet,{"F","1.01.4","0105"," "," "," "," ",aEmpr1[5,2,5],aEmpr1[5,1,5],0,0})//Profissionais altamente qualificados e qualificados
Aadd(aRepEfet,{"F","1.01.4","0106"," "," "," "," ",aEmpr1[5,2,6],aEmpr1[5,1,6],0,0})//Profissionais semiqualificados
Aadd(aRepEfet,{"F","1.01.4","0107"," "," "," "," ",aEmpr1[5,2,7],aEmpr1[5,1,7],0,0})//Profissionais nao qualificados
Aadd(aRepEfet,{"F","1.01.4","0108"," "," "," "," ",aEmpr1[5,2,8],aEmpr1[5,1,8],0,0})//Praticantes\Aprendizes
MsgRun(STR0053,STR0047, {||GravaRGN(aRepEfet)})//"Processando Reparticao de Efetivos"
//Item 1.2 - Numero Medio de pessoas durante o ano
Aadd(aNumMed,{"F","1.02","0101"," "," "," "," ",nMedM11,nMedF11,0,0})//Dirigentes
Aadd(aNumMed,{"F","1.02","0102"," "," "," "," ",nMedM12,nMedF12,0,0})//Quadro Superiores
Aadd(aNumMed,{"F","1.02","0103"," "," "," "," ",nMedM13,nMedF13,0,0})//Quadro Medios
Aadd(aNumMed,{"F","1.02","0104"," "," "," "," ",nMedM14,nMedF14,0,0})//Quadro Intermediarios
Aadd(aNumMed,{"F","1.02","0105"," "," "," "," ",nMedM15,nMedF15,0,0})//Profissionais altamente qualificados e qualificados
Aadd(aNumMed,{"F","1.02","0106"," "," "," "," ",nMedM16,nMedF16,0,0})//Profissionais semiqualificados
Aadd(aNumMed,{"F","1.02","0107"," "," "," "," ",nMedM17,nMedF17,0,0})//Profissionais nao qualificados
Aadd(aNumMed,{"F","1.02","0108"," "," "," "," ",nMedM18,nMedF18,0,0})//Praticantes\Aprendizes
MsgRun(STR0054,STR0047, {||GravaRGN(aNumMed)})//"Processando N° Medio de pessoas"
//Item 1.3 - Estrutura Etária do pessoal da empresa em 31 de dezembro
Aadd(aFaixEta,{"F","1.03","0201" ," "," "," "," ",aEmpr3[1,2] ,aEmpr3[1,1] ,0,0})//Ate 15 Anos
Aadd(aFaixEta,{"F","1.03","0202" ," "," "," "," ",aEmpr3[2,2] ,aEmpr3[2,1] ,0,0})//De 16 a 17 Anos
Aadd(aFaixEta,{"F","1.03","0203" ," "," "," "," ",aEmpr3[3,2] ,aEmpr3[3,1] ,0,0})//De 18 a 24 Anos
Aadd(aFaixEta,{"F","1.03","0204" ," "," "," "," ",aEmpr3[4,2] ,aEmpr3[4,1] ,0,0})//De 25 a 29 Anos
Aadd(aFaixEta,{"F","1.03","0205" ," "," "," "," ",aEmpr3[5,2] ,aEmpr3[5,1] ,0,0})//De 30 a 34 Anos
Aadd(aFaixEta,{"F","1.03","0206" ," "," "," "," ",aEmpr3[6,2] ,aEmpr3[6,1] ,0,0})//De 35 a 39 Anos
Aadd(aFaixEta,{"F","1.03","0207" ," "," "," "," ",aEmpr3[7,2] ,aEmpr3[7,1] ,0,0})//De 40 a 44 Anos
Aadd(aFaixEta,{"F","1.03","0208" ," "," "," "," ",aEmpr3[8,2] ,aEmpr3[8,1] ,0,0})//De 45 a 49 Anos
Aadd(aFaixEta,{"F","1.03","0209" ," "," "," "," ",aEmpr3[9,2] ,aEmpr3[9,1] ,0,0})//De 50 a 54 Anos
Aadd(aFaixEta,{"F","1.03","0210" ," "," "," "," ",aEmpr3[10,2],aEmpr3[10,1],0,0})//De 55 a 59 Anos
Aadd(aFaixEta,{"F","1.03","0211" ," "," "," "," ",aEmpr3[11,2],aEmpr3[11,1],0,0})//De 60 a 61 Anos
Aadd(aFaixEta,{"F","1.03","0212" ," "," "," "," ",aEmpr3[12,2],aEmpr3[12,1],0,0})//De 62 a 64 Anos
Aadd(aFaixEta,{"F","1.03","0213" ," "," "," "," ",aEmpr3[13,2],aEmpr3[13,1],0,0})//De 65 e mais Anos  
//item 1.4 - Media Etaria
Aadd(aFaixEta,{"F","1.04","" ," "," "," "," ",nSumIda/nQtdPes,0,0,0})	
MsgRun(STR0055,STR0047, {||GravaRGN(aFaixEta)})//"Processando Estrutura Etaria"
			
//Item 1.5 - Nivel de Antiguidade do pessoal ao servico em 31 de dezembro
Aadd(aFuncAnt,{"F","1.05","0301" ," "," "," "," ",aEmpr3[14,2],aEmpr3[14,1],0,0})//Ate 1 Ano
Aadd(aFuncAnt,{"F","1.05","0302" ," "," "," "," ",aEmpr3[15,2],aEmpr3[15,1],0,0})//Mais de 1 ate 2 Anos
Aadd(aFuncAnt,{"F","1.05","0303" ," "," "," "," ",aEmpr3[16,2],aEmpr3[16,1],0,0})//Mais de 2 ate 5 Anos
Aadd(aFuncAnt,{"F","1.05","0304" ," "," "," "," ",aEmpr3[17,2],aEmpr3[17,1],0,0})//Mais de 5 ate 10 Anos
Aadd(aFuncAnt,{"F","1.05","0305" ," "," "," "," ",aEmpr3[18,2],aEmpr3[18,1],0,0})//Mais de 10 ate 15 Anos
Aadd(aFuncAnt,{"F","1.05","0306" ," "," "," "," ",aEmpr3[19,2],aEmpr3[19,1],0,0})//Mais de 15 Anos
MsgRun(STR0056,STR0047, {||GravaRGN(aFuncAnt)})//"Processando Antiguidade"
//Item 1.6 - Trabalhadores Estrangeiros
Aadd(aFuncEst,{"F","1.06","0401" ," "," "," "," ",aEmpr3[20,2],aEmpr3[20,1] ,0,0})//Paises da Uniao Europeia
Aadd(aFuncEst,{"F","1.06","0402" ," "," "," "," ",aEmpr3[21,2],aEmpr3[21,1] ,0,0})//Paises Africanos da Lingua Oficial portuguessa
Aadd(aFuncEst,{"F","1.06","0403" ," "," "," "," ",aEmpr3[22,2],aEmpr3[22,1] ,0,0})//Brasil
Aadd(aFuncEst,{"F","1.06","0404" ," "," "," "," ",aEmpr3[23,2],aEmpr3[23,1] ,0,0})//Outros Paises
MsgRun(STR0057,STR0047, {||GravaRGN(aFuncEst)})//"Processando Estrangeiros"
//Item 1.7 - Trabalhadores Deficientes
Aadd(aFuncDef,{"F","1.07"," "    ," "," "," "," ",aEmpr3[24,2],aEmpr3[24,1],0,0})//Deficientes
MsgRun(STR0058,STR0047, {||GravaRGN(aFuncDef)})//"Processando Deficiente"
//Item 1.8 - Estrutura de Niveis de Habilitação do pessoal ao servico em 31 de dezembro
Aadd(aFuncNiv,{"F","1.08","0501" ," "," "," "," ",aEmpr3[25,2],aEmpr3[25,1],0,0})//Inferior ao 1 ciclo do ensino basico
Aadd(aFuncNiv,{"F","1.08","0502" ," "," "," "," ",aEmpr3[26,2],aEmpr3[26,1],0,0})//1 Ciclo de ensino basico
Aadd(aFuncNiv,{"F","1.08","0503" ," "," "," "," ",aEmpr3[27,2],aEmpr3[27,1],0,0})//2 Ciclo de ensino basico
Aadd(aFuncNiv,{"F","1.08","0504" ," "," "," "," ",aEmpr3[28,2],aEmpr3[28,1],0,0})//3 Ciclo de ensino basico
Aadd(aFuncNiv,{"F","1.08","0505" ," "," "," "," ",aEmpr3[29,2],aEmpr3[29,1],0,0})//Ensino Secundario
Aadd(aFuncNiv,{"F","1.08","0506" ," "," "," "," ",aEmpr3[30,2],aEmpr3[30,1],0,0})//Ensino Superior de Indole Profissional
Aadd(aFuncNiv,{"F","1.08","0507" ," "," "," "," ",aEmpr3[31,2],aEmpr3[31,1],0,0})//Ensino Superior Politecnico
Aadd(aFuncNiv,{"F","1.08","0508" ," "," "," "," ",aEmpr3[32,2],aEmpr3[32,1],0,0})//Ensino superior Universitario
Aadd(aFuncNiv,{"F","1.08","0509" ," "," "," "," ",aEmpr3[33,2],aEmpr3[33,1],0,0})//Outros
MsgRun(STR0059,STR0047, {||GravaRGN(aFuncNiv)})//"Processando Nivel de Habilitacao"                      
//CONTRATOS A TERMO
//Posicao  6 ->Item 1.9.1 - Com Contrato a Termo Certo(Contratos a Termo)
//Posicao  7 ->Item 1.9.2 - Com Contrato a Termo Incerto(Contratos a Termo)
//Posicao  8 ->Item 1.9.3 - Contratados a Termo que passaram ao Q.Permanente(Contratos a Termo)
//Posicao  9 ->Item 1.9.4 - Contratados a Termo que Transitaramdo ano anterior(Contratos a Termo)
//1.9 *************CONTRATADOS A TERMO
//Item 1.9.1 - Contratos a Termo Certo (Contratos a Termo)
Aadd(aContTer,{"F","1.09.1","0102"," "," "," "," ",aEmpr1[6,2,2],aEmpr1[6,1,2],0,0})//Quadro Superiores
Aadd(aContTer,{"F","1.09.1","0103"," "," "," "," ",aEmpr1[6,2,3],aEmpr1[6,1,3],0,0})//Quadro Medios
Aadd(aContTer,{"F","1.09.1","0104"," "," "," "," ",aEmpr1[6,2,4],aEmpr1[6,1,4],0,0})//Quadro Intermediarios
Aadd(aContTer,{"F","1.09.1","0105"," "," "," "," ",aEmpr1[6,2,5],aEmpr1[6,1,5],0,0})//Profissionais altamente qualificados e qualificados
Aadd(aContTer,{"F","1.09.1","0106"," "," "," "," ",aEmpr1[6,2,6],aEmpr1[6,1,6],0,0})//Profissionais semiqualificados
Aadd(aContTer,{"F","1.09.1","0107"," "," "," "," ",aEmpr1[6,2,7],aEmpr1[6,1,7],0,0})//Profissionais nao qualificados
Aadd(aContTer,{"F","1.09.1","0108"," "," "," "," ",aEmpr1[6,2,8],aEmpr1[6,1,8],0,0})//Praticantes\Aprendizes
//Item 1.9.2 - Contratos a Termo InCerto(Contratos a Termo)
Aadd(aContTer,{"F","1.09.2","0102"," "," "," "," ",aEmpr1[7,2,2],aEmpr1[7,1,2],0,0})//Quadro Superiores
Aadd(aContTer,{"F","1.09.2","0103"," "," "," "," ",aEmpr1[7,2,3],aEmpr1[7,1,3],0,0})//Quadro Medios
Aadd(aContTer,{"F","1.09.2","0104"," "," "," "," ",aEmpr1[7,2,4],aEmpr1[7,1,4],0,0})//Quadro Intermediarios
Aadd(aContTer,{"F","1.09.2","0105"," "," "," "," ",aEmpr1[7,2,5],aEmpr1[6,1,5],0,0})//Profissionais altamente qualificados e qualificados
Aadd(aContTer,{"F","1.09.2","0106"," "," "," "," ",aEmpr1[7,2,6],aEmpr1[7,1,6],0,0})//Profissionais semiqualificados
Aadd(aContTer,{"F","1.09.2","0107"," "," "," "," ",aEmpr1[7,2,7],aEmpr1[7,1,7],0,0})//Profissionais nao qualificados
Aadd(aContTer,{"F","1.09.2","0108"," "," "," "," ",aEmpr1[7,2,8],aEmpr1[7,1,8],0,0})//Praticantes\Aprendizes
//Item 1.9.3 - Contratados a Termo que passaram ao Q.Permanente(Contratos a Termo)
Aadd(aContTer,{"F","1.09.3","0102"," "," "," "," ",aEmpr1[8,2,2],aEmpr1[8,1,2],0,0})//Quadro Superiores
Aadd(aContTer,{"F","1.09.3","0103"," "," "," "," ",aEmpr1[8,2,3],aEmpr1[8,1,3],0,0})//Quadro Medios
Aadd(aContTer,{"F","1.09.3","0104"," "," "," "," ",aEmpr1[8,2,4],aEmpr1[8,1,4],0,0})//Quadro Intermediarios
Aadd(aContTer,{"F","1.09.3","0105"," "," "," "," ",aEmpr1[8,2,5],aEmpr1[8,1,5],0,0})//Profissionais altamente qualificados e qualificados
Aadd(aContTer,{"F","1.09.3","0106"," "," "," "," ",aEmpr1[8,2,6],aEmpr1[8,1,6],0,0})//Profissionais semiqualificados
Aadd(aContTer,{"F","1.09.3","0107"," "," "," "," ",aEmpr1[8,2,7],aEmpr1[8,1,7],0,0})//Profissionais nao qualificados
Aadd(aContTer,{"F","1.09.3","0108"," "," "," "," ",aEmpr1[8,2,8],aEmpr1[8,1,8],0,0})//Praticantes\Aprendizes
//Item 1.9.4 - Contratados a termo que transitaram do ano anterior (Contratos a Termo)
Aadd(aContTer,{"F","1.09.4","0102"," "," "," "," ",aEmpr1[9,2,2],aEmpr1[9,1,2],0,0})//Quadro Superiores
Aadd(aContTer,{"F","1.09.4","0103"," "," "," "," ",aEmpr1[9,2,3],aEmpr1[9,1,3],0,0})//Quadro Medios
Aadd(aContTer,{"F","1.09.4","0104"," "," "," "," ",aEmpr1[9,2,4],aEmpr1[9,1,4],0,0})//Quadro Intermediarios
Aadd(aContTer,{"F","1.09.4","0105"," "," "," "," ",aEmpr1[9,2,5],aEmpr1[9,1,5],0,0})//Profissionais altamente qualificados e qualificados
Aadd(aContTer,{"F","1.09.4","0106"," "," "," "," ",aEmpr1[9,2,6],aEmpr1[9,1,6],0,0})//Profissionais semiqualificados
Aadd(aContTer,{"F","1.09.4","0107"," "," "," "," ",aEmpr1[9,2,7],aEmpr1[9,1,7],0,0})//Profissionais nao qualificados
Aadd(aContTer,{"F","1.09.4","0108"," "," "," "," ",aEmpr1[9,2,8],aEmpr1[9,1,8],0,0})//Praticantes\Aprendizes
//Item 1.9.5 - Numero Medio de contratados (Contratos a Termo)
Aadd(aContTer,{"F","1.09.5","0102"," "," "," "," ",nMedM2,nMedF2,0,0})//Quadro Superiores
Aadd(aContTer,{"F","1.09.5","0103"," "," "," "," ",nMedM3,nMedF3,0,0})//Quadro Medios
Aadd(aContTer,{"F","1.09.5","0104"," "," "," "," ",nMedM4,nMedF4,0,0})//Quadro Intermediarios
Aadd(aContTer,{"F","1.09.5","0105"," "," "," "," ",nMedM5,nMedF5,0,0})//Profissionais altamente qualificados e qualificados
Aadd(aContTer,{"F","1.09.5","0106"," "," "," "," ",nMedM6,nMedF6,0,0})//Profissionais semiqualificados
Aadd(aContTer,{"F","1.09.5","0107"," "," "," "," ",nMedM7,nMedF7,0,0})//Profissionais nao qualificados
Aadd(aContTer,{"F","1.09.5","0108"," "," "," "," ",nMedM8,nMedF8,0,0})//Praticantes\Aprendizes
MsgRun(STR0060,STR0047, {||GravaRGN(aContTer)})//"Processando Contrato a Termo"
//MOVIMENTO DE SAIDA
//Posicao 10->Item 1.10.1 - Saida de Pessoal com Contrato Permanente (Movimento de Saída)
//Posicao 11->Item 1.10.2 - Saida de Pessoal com Contrato Termo Certo e Incerto(Movimento de Saida)
//Posicao 12->Item 1.10.3 - Saida de Outros Trabalhadores(Movimento de Saída)
//1.10 *************MOVIMENTOS DE SAIDAS
//Item 1.10.1 - Saida de Pessoal com Contrato Permanente(Movimento de Saida)
Aadd(aMovSaid,{"F","1.10.1","0102"," "," "," "," ",aEmpr1[10,2,2],aEmpr1[10,1,2],0,0})//Quadro Superiores
Aadd(aMovSaid,{"F","1.10.1","0103"," "," "," "," ",aEmpr1[10,2,3],aEmpr1[10,1,3],0,0})//Quadro Medios
Aadd(aMovSaid,{"F","1.10.1","0104"," "," "," "," ",aEmpr1[10,2,4],aEmpr1[10,1,4],0,0})//Quadro Intermediarios
Aadd(aMovSaid,{"F","1.10.1","0105"," "," "," "," ",aEmpr1[10,2,5],aEmpr1[10,1,5],0,0})//Profissionais altamente qualificados e qualificados
Aadd(aMovSaid,{"F","1.10.1","0106"," "," "," "," ",aEmpr1[10,2,6],aEmpr1[10,1,6],0,0})//Profissionais semiqualificados
Aadd(aMovSaid,{"F","1.10.1","0107"," "," "," "," ",aEmpr1[10,2,7],aEmpr1[10,1,7],0,0})//Profissionais nao qualificados
Aadd(aMovSaid,{"F","1.10.1","0108"," "," "," "," ",aEmpr1[10,2,8],aEmpr1[10,1,8],0,0})//Praticantes\Aprendizes
//Item 1.10.2 - Saida de Pessoal com Contrato Termo Certo e Incerto(Movimento de Saida)
Aadd(aMovSaid,{"F","1.10.2","0102"," "," "," "," ",aEmpr1[11,2,2],aEmpr1[11,1,2],0,0})//Quadro Superiores
Aadd(aMovSaid,{"F","1.10.2","0103"," "," "," "," ",aEmpr1[11,2,3],aEmpr1[11,1,3],0,0})//Quadro Medios
Aadd(aMovSaid,{"F","1.10.2","0104"," "," "," "," ",aEmpr1[11,2,4],aEmpr1[11,1,4],0,0})//Quadro Intermediarios
Aadd(aMovSaid,{"F","1.10.2","0105"," "," "," "," ",aEmpr1[11,2,5],aEmpr1[11,1,5],0,0})//Profissionais altamente qualificados e qualificados
Aadd(aMovSaid,{"F","1.10.2","0106"," "," "," "," ",aEmpr1[11,2,6],aEmpr1[11,1,6],0,0})//Profissionais semiqualificados
Aadd(aMovSaid,{"F","1.10.2","0107"," "," "," "," ",aEmpr1[11,2,7],aEmpr1[11,1,7],0,0})//Profissionais nao qualificados
Aadd(aMovSaid,{"F","1.10.2","0108"," "," "," "," ",aEmpr1[11,2,8],aEmpr1[11,1,8],0,0})//Praticantes\Aprendizes
//Item 1.10.3 - Saida de Outros Trabalhadores(Movimento de Saida)
Aadd(aMovSaid,{"F","1.10.3","0102"," "," "," "," ",aEmpr1[12,2,2],aEmpr1[12,1,2],0,0})//Quadro Superiores
Aadd(aMovSaid,{"F","1.10.3","0103"," "," "," "," ",aEmpr1[12,2,3],aEmpr1[12,1,3],0,0})//Quadro Medios
Aadd(aMovSaid,{"F","1.10.3","0104"," "," "," "," ",aEmpr1[12,2,4],aEmpr1[12,1,4],0,0})//Quadro Intermediarios
Aadd(aMovSaid,{"F","1.10.3","0105"," "," "," "," ",aEmpr1[12,2,5],aEmpr1[12,1,5],0,0})//Profissionais altamente qualificados e qualificados
Aadd(aMovSaid,{"F","1.10.3","0106"," "," "," "," ",aEmpr1[12,2,6],aEmpr1[12,1,6],0,0})//Profissionais semiqualificados
Aadd(aMovSaid,{"F","1.10.3","0107"," "," "," "," ",aEmpr1[12,2,7],aEmpr1[12,1,7],0,0})//Profissionais nao qualificados
Aadd(aMovSaid,{"F","1.10.3","0108"," "," "," "," ",aEmpr1[12,2,8],aEmpr1[12,1,8],0,0})//Praticantes\Aprendizes
MsgRun(STR0061,STR0047, {||GravaRGN(aMovSaid)})//"Processando Movimento de Saida"
//1.11 *************MOTIVOS DE SAIDAS DO PESSOAL COM CONTRATO PERMANENTE
//1.12 *************MOTIVOS DE SAIDAS DO PESSOAL COM CONTRATO A TERMO
//1.13 *************OUTRO MOTIVO DE SAIDA DO PESSOAL COM CONTRATO PERMANENTE OU A TERMO
MotSaida()
//1.14 ************* POSTOS DE TRABALHO NAO OCUPADOS POR DIFICULDADE DE RECRUTAMENTO
PostTrab()
//1.15 ************* PROMOCOES
//PROMOCOES
//Posicao 13->Item 1.15.1 -  Antiguidade
//Posicao 14->Item 1.15.3 -  Merito
//Posicao 15->Item 1.15.4 -  Outras

//Item 1.15.1 - Antiguidade(Promocoes)   
Aadd(aPromoc,{"F","1.15.1","0102"," "," "," "," ",aEmpr1[13,2,2],aEmpr1[13,1,2],0,0})//Quadro Superiores
Aadd(aPromoc,{"F","1.15.1","0103"," "," "," "," ",aEmpr1[13,2,3],aEmpr1[13,1,3],0,0})//Quadro Medios        
Aadd(aPromoc,{"F","1.15.1","0104"," "," "," "," ",aEmpr1[13,2,4],aEmpr1[13,1,4],0,0})//Quadro Intermediarios
Aadd(aPromoc,{"F","1.15.1","0105"," "," "," "," ",aEmpr1[13,2,5],aEmpr1[13,1,5],0,0})//Profissionais altamente qualificados e qualificados
Aadd(aPromoc,{"F","1.15.1","0106"," "," "," "," ",aEmpr1[13,2,6],aEmpr1[13,1,6],0,0})//Profissionais semiqualificados
Aadd(aPromoc,{"F","1.15.1","0107"," "," "," "," ",aEmpr1[13,2,7],aEmpr1[13,1,7],0,0})//Profissionais nao qualificados
Aadd(aPromoc,{"F","1.15.1","0108"," "," "," "," ",aEmpr1[13,2,8],aEmpr1[13,1,8],0,0})//Praticantes\Aprendizes

//Item 1.15.2 - Merito(Promocoes)
Aadd(aPromoc,{"F","1.15.2","0102"," "," "," "," ",aEmpr1[14,2,2],aEmpr1[14,1,2],0,0})//Quadro Superiores
Aadd(aPromoc,{"F","1.15.2","0103"," "," "," "," ",aEmpr1[14,2,3],aEmpr1[14,1,3],0,0})//Quadro Medios        
Aadd(aPromoc,{"F","1.15.2","0104"," "," "," "," ",aEmpr1[14,2,4],aEmpr1[14,1,4],0,0})//Quadro Intermediarios
Aadd(aPromoc,{"F","1.15.2","0105"," "," "," "," ",aEmpr1[14,2,5],aEmpr1[14,1,5],0,0})//Profissionais altamente qualificados e qualificados
Aadd(aPromoc,{"F","1.15.2","0106"," "," "," "," ",aEmpr1[14,2,6],aEmpr1[14,1,6],0,0})//Profissionais semiqualificados
Aadd(aPromoc,{"F","1.15.2","0107"," "," "," "," ",aEmpr1[14,2,7],aEmpr1[14,1,7],0,0})//Profissionais nao qualificados
Aadd(aPromoc,{"F","1.15.2","0108"," "," "," "," ",aEmpr1[14,2,8],aEmpr1[14,1,8],0,0})//Praticantes\Aprendizes

//Item 1.15.3 - Outros(Promocoes)
Aadd(aPromoc,{"F","1.15.3","0102"," "," "," "," ",aEmpr1[15,2,2],aEmpr1[15,1,2],0,0})//Quadro Superiores
Aadd(aPromoc,{"F","1.15.3","0103"," "," "," "," ",aEmpr1[15,2,3],aEmpr1[15,1,3],0,0})//Quadro Medios        
Aadd(aPromoc,{"F","1.15.3","0104"," "," "," "," ",aEmpr1[15,2,4],aEmpr1[15,1,4],0,0})//Quadro Intermediarios
Aadd(aPromoc,{"F","1.15.3","0105"," "," "," "," ",aEmpr1[15,2,5],aEmpr1[15,1,5],0,0})//Profissionais altamente qualificados e qualificados
Aadd(aPromoc,{"F","1.15.3","0106"," "," "," "," ",aEmpr1[15,2,6],aEmpr1[15,1,6],0,0})//Profissionais semiqualificados
Aadd(aPromoc,{"F","1.15.3","0107"," "," "," "," ",aEmpr1[15,2,7],aEmpr1[15,1,7],0,0})//Profissionais nao qualificados
Aadd(aPromoc,{"F","1.15.3","0108"," "," "," "," ",aEmpr1[15,2,8],aEmpr1[15,1,8],0,0})//Praticantes\Aprendizes

MsgRun(STR0062,STR0047, {||GravaRGN(aPromoc)})//"Processando Promocao"
//1.16 - RECONVERSOES/RECLASSIFICACOES
//RECONVERSOES/RECLASSIFICACAO
//Posicao 16->Item 1.16.1 -  Numero Trabalhadores(Quadro Superior)
//Posicao 17->Item 1.16.3 -  Numero Trabalhadores(Quadro Medio)
//Posicao 18->Item 1.16.4 -  Numero Trabalhadores(Quadro Intermediario)
//Posicao 19->Item 1.16.1 -  Numero Trabalhadores(Profissional Altamente Qualificado e Qualificado)
//Posicao 20->Item 1.16.3 -  Numero Trabalhadores(Profissional Semi-Qualificado)
//Posicao 21->Item 1.16.4 -  Numero Trabalhadores(Profissional nao Qualificado
//Posicao 22->Item 1.16.1 -  Numero Trabalhadores(Praticante/Aprendiz)


Aadd(aReclass,{"F","1.16","0102"," "," "," "," ",aEmpr1[16,2,2],aEmpr1[16,1,2],0,0})//Quadro Superiores
Aadd(aReclass,{"F","1.16","0103"," "," "," "," ",aEmpr1[16,2,3],aEmpr1[16,1,3],0,0})//Quadro Medios
Aadd(aReclass,{"F","1.16","0104"," "," "," "," ",aEmpr1[16,2,4],aEmpr1[16,1,4],0,0})//Quadro Intermediarios
Aadd(aReclass,{"F","1.16","0105"," "," "," "," ",aEmpr1[16,2,5],aEmpr1[16,1,5],0,0})//Profissionais altamente qualificados e qualificados
Aadd(aReclass,{"F","1.16","0106"," "," "," "," ",aEmpr1[16,2,6],aEmpr1[16,1,6],0,0})//Profissionais semiqualificados
Aadd(aReclass,{"F","1.16","0107"," "," "," "," ",aEmpr1[16,2,7],aEmpr1[16,1,7],0,0})//Profissionais nao qualificados
Aadd(aReclass,{"F","1.16","0108"," "," "," "," ",aEmpr1[16,2,8],aEmpr1[16,1,8],0,0})//Praticantes\Aprendizes
MsgRun(STR0063,STR0047, {||GravaRGN(aReclass)})//"Processando Reconversoes\Reclassificacao"
//1.17 ************* TEMPO DE TRABALHO
//Item 1.17.1 - Periodo Normal de Trabalho em Vigor em Dezembro                    
//Item 1.17.2 - Tipos de horario predominante durante o ano
//Item 1.17.3 - Potencial Maximo Anual(Horas Trabalhaveis)
//Item 1.17.4 - Total Horas efetivamente trabalhadas
//1.17.5 ************* TRABALHO SUPLEMENTAR/HORAS EXTRAORDINARIAS
//Item 1.17.5.1 - Em dias úteis
//Item 1.17.5.2 - Em dia de descanso complementar e feriados
//Item 1.17.5.3 - Em dia de descanso obrigatario
//1.18 ************* AUSENCIA AO TRABALHO
AusTrab()  
//1.19 ************* HORAS NAO TRABALHADAS
//Item 1.19.1 - Por formacao profissional - Obs.Item a ser preenchido manualmente
//Item 1.19.2 - Por reducao legal da atividade
//Item 1.19.3 - Por desemprego interno
//Item 1.19.4 - Por descanso suplementar  
//Item 1.19.5 - Por Greves/Paralizacoes - Obs.Item a ser preenchido manualmente

//==================================================================
//MONTAGEM DO LOG DO BALANCO SOCIAL - EMPREGOS                    
//==================================================================
aAdd( aLogProc, {"1",STR0064            ,"000"} )   //"EMPREGO"
aAdd( aLogProc, {"1",Replicate("*",130),"001"} )
aAdd( aLogProc, {"1",STR0065           ,"002"} )//"1 - Reparticao de Efetivos:"
aAdd( aLogProc, {"1",STR0066           ,"003"} )//"1.1 - Pessoas ao servico em 31 de Dezembro: "
aAdd( aLogProc, {"1","         "+STR0067+"   "+STR0068+"   "+STR0069+"    "+STR0070+"    "+STR0071+"    "+STR0072+" "+STR0073+" "+STR0074+" ","004"} )
aAdd( aLogProc, {"1",STR0075+"   "+Transform(aEmpr1[1,1,1],"@E 999999")+'        '+Transform(aEmpr1[1,2,2],"@E 999999")+'        '+Transform(aEmpr1[1,2,3],"@E 999999")+'        '+Transform(aEmpr1[1,2,4],"@E 999999");
+'            '+Transform(aEmpr1[1,2,5],"@E 999999")+'        '+Transform(aEmpr1[1,2,6],"@E 999999")+'        '+Transform(aEmpr1[1,2,7],"@E 999999")+'        '+Transform(aEmpr1[1,2,8],"@E 999999"),"005"} )
aAdd( aLogProc, {"1",STR0076+"   "+Transform(aEmpr1[1,1,1],"@E 999999")+'        '+Transform(aEmpr1[1,1,2],"@E 999999")+'        '+Transform(aEmpr1[1,1,3],"@E 999999")+'        '+Transform(aEmpr1[1,1,4],"@E 999999");
+'            '+Transform(aEmpr1[1,1,5],"@E 999999")+'        '+Transform(aEmpr1[1,1,6],"@E 999999")+'        '+Transform(aEmpr1[1,1,7],"@E 999999")+'        '+Transform(aEmpr1[1,1,8],"@E 999999"),"006"} )
aAdd( aLogProc, {"1",Space(10)+Replicate("-",120),"007"})
aAdd( aLogProc, {"1",STR0077,"008"} )//"   1.1.1 - Com Contrato permanente: "
aAdd( aLogProc, {"1","         "+STR0067+"   "+STR0068+"   "+STR0069+"    "+STR0070+"    "+STR0071+"    "+STR0072+" "+STR0073+" "+STR0074+" ","009"} )
aAdd( aLogProc, {"1","   "+STR0075+"   "+Transform(aEmpr1[2,2,1],"@E 999999")+'        '+Transform(aEmpr1[2,2,2],"@E 999999")+'        '+Transform(aEmpr1[2,2,3],"@E 999999")+'        '+Transform(aEmpr1[2,2,4],"@E 999999");
+'            '+Transform(aEmpr1[2,2,5],"@E 999999")+'        '+Transform(aEmpr1[2,2,6],"@E 999999")+'        '+Transform(aEmpr1[2,2,7],"@E 999999")+'        '+Transform(aEmpr1[2,2,8],"@E 999999"),"010"} )
aAdd( aLogProc, {"1","   "+STR0076+"   "+Transform(aEmpr1[2,1,1],"@E 999999")+'        '+Transform(aEmpr1[2,1,2],"@E 999999")+'        '+Transform(aEmpr1[2,1,3],"@E 999999")+'        '+Transform(aEmpr1[2,1,4],"@E 999999");
+'            '+Transform(aEmpr1[2,1,5],"@E 999999")+'        '+Transform(aEmpr1[2,1,6],"@E 999999")+'        '+Transform(aEmpr1[2,1,7],"@E 999999")+'        '+Transform(aEmpr1[2,1,8],"@E 999999"),"011"} )
aAdd( aLogProc, {"1"," ","012"})
aAdd( aLogProc, {"1",STR0078,"013"} )//"   1.1.2 - Contrato a Termo Certo: "
aAdd( aLogProc, {"1","         "+STR0067+"   "+STR0068+"   "+STR0069+"    "+STR0070+"    "+STR0071+"    "+STR0072+" "+STR0073+" "+STR0074+" ","014"} )
aAdd( aLogProc, {"1","   "+STR0075+"   "+Transform(aEmpr1[3,2,1],"@E 999999")+'        '+Transform(aEmpr1[3,2,2],"@E 999999")+'        '+Transform(aEmpr1[3,2,3],"@E 999999")+'        '+Transform(aEmpr1[3,2,4],"@E 999999");
+'            '+Transform(aEmpr1[3,2,5],"@E 999999")+'        '+Transform(aEmpr1[3,2,6],"@E 999999")+'        '+Transform(aEmpr1[3,2,7],"@E 999999")+'        '+Transform(aEmpr1[3,2,8],"@E 999999"),"015"} )
aAdd( aLogProc, {"1","   "+STR0076+"   "+Transform(aEmpr1[3,1,1],"@E 999999")+'        '+Transform(aEmpr1[3,1,2],"@E 999999")+'        '+Transform(aEmpr1[3,1,3],"@E 999999")+'        '+Transform(aEmpr1[3,1,4],"@E 999999");
+'            '+Transform(aEmpr1[3,1,5],"@E 999999")+'        '+Transform(aEmpr1[3,1,6],"@E 999999")+'        '+Transform(aEmpr1[3,1,7],"@E 999999")+'        '+Transform(aEmpr1[3,1,8],"@E 999999"),"016"} )
aAdd( aLogProc, {"1"," ","017"})
aAdd( aLogProc, {"1",STR0079,"018"} )//"   1.1.3 - Contrato a Termo Incerto: "
aAdd( aLogProc, {"1","         "+STR0067+"   "+STR0068+"   "+STR0069+"    "+STR0070+"    "+STR0071+"    "+STR0072+" "+STR0073+" "+STR0074+" ","019"} )
aAdd( aLogProc, {"1","   "+STR0075+"   "+Transform(aEmpr1[4,2,1],"@E 999999")+'        '+Transform(aEmpr1[4,2,2],"@E 999999")+'        '+Transform(aEmpr1[4,2,3],"@E 999999")+'        '+Transform(aEmpr1[4,2,4],"@E 999999");
+'            '+Transform(aEmpr1[4,2,5],"@E 999999")+'        '+Transform(aEmpr1[4,2,6],"@E 999999")+'        '+Transform(aEmpr1[4,2,7],"@E 999999")+'        '+Transform(aEmpr1[4,2,8],"@E 999999"),"020"} )
aAdd( aLogProc, {"1","   "+STR0076+"   "+Transform(aEmpr1[1,1,1],"@E 999999")+'        '+Transform(aEmpr1[4,1,2],"@E 999999")+'        '+Transform(aEmpr1[4,1,3],"@E 999999")+'        '+Transform(aEmpr1[4,1,4],"@E 999999");
+'            '+Transform(aEmpr1[4,1,5],"@E 999999")+'        '+Transform(aEmpr1[4,1,6],"@E 999999")+'        '+Transform(aEmpr1[4,1,7],"@E 999999")+'        '+Transform(aEmpr1[4,1,8],"@E 999999"),"021"} )
aAdd( aLogProc, {"1"," ","022"})
aAdd( aLogProc, {"1",STR0080,"023"} )//"   1.1.4 - Outros: "
aAdd( aLogProc, {"1","         "+STR0067+"   "+STR0068+"   "+STR0069+"    "+STR0070+"    "+STR0071+"    "+STR0072+" "+STR0073+" "+STR0074+" ","024"} )
aAdd( aLogProc, {"1","   "+STR0075+"   "+Transform(aEmpr1[5,2,1],"@E 999999")+'        '+Transform(aEmpr1[5,2,2],"@E 999999")+'        '+Transform(aEmpr1[5,2,3],"@E 999999")+'        '+Transform(aEmpr1[5,2,4],"@E 999999");
+'            '+Transform(aEmpr1[5,2,5],"@E 999999")+'        '+Transform(aEmpr1[5,2,6],"@E 999999")+'        '+Transform(aEmpr1[5,2,7],"@E 999999")+'        '+Transform(aEmpr1[5,2,8],"@E 999999"),"025"} )
aAdd( aLogProc, {"1","   "+STR0076+"   "+Transform(aEmpr1[5,1,1],"@E 999999")+'        '+Transform(aEmpr1[5,1,2],"@E 999999")+'        '+Transform(aEmpr1[1,1,3],"@E 999999")+'        '+Transform(aEmpr1[5,1,4],"@E 999999");
+'            '+Transform(aEmpr1[5,1,5],"@E 999999")+'        '+Transform(aEmpr1[5,1,6],"@E 999999")+'        '+Transform(aEmpr1[5,1,7],"@E 999999")+'        '+Transform(aEmpr1[5,1,8],"@E 999999"),"026"} )
//Numero Medio de Pessoas
aAdd( aLogProc, {"1",Replicate("-",130),"027"})
aAdd( aLogProc, {"1",STR0081,"028"} )//"1.2 - Numero Medio de pessoas durante o ano: "
aAdd( aLogProc, {"1","         "+STR0067+"   "+STR0068+"   "+STR0069+"    "+STR0070+"    "+STR0071+"    "+STR0072+" "+STR0073+" "+STR0074+" ","029"} )
aAdd( aLogProc, {"1","   "+STR0075+"   "+Transform(nMedM11,"@E 999999")+'        '+Transform(nMedM12,"@E 999999")+'        '+Transform(nMedM13,"@E 999999")+'        '+Transform(nMedM14,"@E 999999");
+'            '+Transform(nMedM15,"@E 999999")+'        '+Transform(nMedM16,"@E 999999")+'        '+Transform(nMedM17,"@E 999999")+'        '+Transform(nMedM18,"@E 999999"),"030"} )
aAdd( aLogProc, {"1","   "+STR0076+"   "+Transform(nMedF11,"@E 999999")+'        '+Transform(nMedF12,"@E 999999")+'        '+Transform(nMedF13,"@E 999999")+'        '+Transform(nMedM14,"@E 999999");
+'            '+Transform(nMedF15,"@E 999999")+'        '+Transform(nMedF16,"@E 999999")+'        '+Transform(nMedF17,"@E 999999")+'        '+Transform(nMedF18,"@E 999999"),"031"} )
//Estrutura Etaria
aAdd( aLogProc, {"1",Replicate("-",130),"033"})
aAdd( aLogProc, {"1",STR0082,"034"} )//"1.3 - Estrutura Etária do pessoal da empresa em 31 de dezembro"
aAdd( aLogProc, {"1",STR0102,"035"})//"Homem   Mulheres"
aAdd( aLogProc, {"1",Transform(aEmpr3[1,2] ,"@E 999999")+"     "+Transform(aEmpr3[1,1]  ,"@E 999999")+"   "+STR0103 ,"036"})//Ate 15 Anos
aAdd( aLogProc, {"1",Transform(aEmpr3[2,2] ,"@E 999999")+"     "+Transform(aEmpr3[2,1]  ,"@E 999999")+"   "+STR0104 ,"037"})//De 16 a 17 Anos
aAdd( aLogProc, {"1",Transform(aEmpr3[3,2] ,"@E 999999")+"     "+Transform(aEmpr3[3,1]  ,"@E 999999")+"   "+STR0105 ,"038"})//De 18 a 24 Anos
aAdd( aLogProc, {"1",Transform(aEmpr3[4,2] ,"@E 999999")+"     "+Transform(aEmpr3[4,1]  ,"@E 999999")+"   "+STR0106 ,"039"})//De 25 a 29 Anos
aAdd( aLogProc, {"1",Transform(aEmpr3[5,2] ,"@E 999999")+"     "+Transform(aEmpr3[5,1]  ,"@E 999999")+"   "+STR0107 ,"040"})//De 30 a 34 Anos
aAdd( aLogProc, {"1",Transform(aEmpr3[6,2] ,"@E 999999")+"     "+Transform(aEmpr3[6,1]  ,"@E 999999")+"   "+STR0108 ,"041"})//De 35 a 39 Anos
aAdd( aLogProc, {"1",Transform(aEmpr3[7,2] ,"@E 999999")+"     "+Transform(aEmpr3[7,1]  ,"@E 999999")+"   "+STR0109 ,"042"})//De 40 a 44 Anos
aAdd( aLogProc, {"1",Transform(aEmpr3[8,2] ,"@E 999999")+"     "+Transform(aEmpr3[8,1]  ,"@E 999999")+"   "+STR0110 ,"043"})//De 45 a 49 Anos
aAdd( aLogProc, {"1",Transform(aEmpr3[9,2] ,"@E 999999")+"     "+Transform(aEmpr3[9,1]  ,"@E 999999")+"   "+STR0111 ,"044"})//De 50 a 54 Anos
aAdd( aLogProc, {"1",Transform(aEmpr3[10,2],"@E 999999")+"     "+Transform(aEmpr3[10,1] ,"@E 999999")+"   "+STR0112 ,"045"})//De 55 a 59 Anos
aAdd( aLogProc, {"1",Transform(aEmpr3[11,2],"@E 999999")+"     "+Transform(aEmpr3[11,1] ,"@E 999999")+"   "+STR0113 ,"046"})//De 60 a 61 Anos
aAdd( aLogProc, {"1",Transform(aEmpr3[12,2],"@E 999999")+"     "+Transform(aEmpr3[12,1] ,"@E 999999")+"   "+STR0114 ,"047"})//De 62 a 64 Anos
aAdd( aLogProc, {"1",Transform(aEmpr3[13,2],"@E 999999")+"     "+Transform(aEmpr3[13,1] ,"@E 999999")+"   "+STR0115 ,"048"})//65 e mais Anos
//Nivel de Antiguidade do pessoal ao servico em 31 de dezembro          
aAdd( aLogProc, {"1",Replicate("-",130),"049"})
aAdd( aLogProc, {"1",STR0083,"050"} )//"1.5 - Nivel de Antiguidade do pessoal ao servico em 31 de dezembro"
aAdd( aLogProc, {"1",STR0102,"051"})//"Homem   Mulheres"
aAdd( aLogProc, {"1",Transform(aEmpr3[14,2] ,"@E 999999")+"     "+Transform(aEmpr3[14,1] ,"@E 999999")+"   "+STR0116,"052"})//Ate 1 Ano
aAdd( aLogProc, {"1",Transform(aEmpr3[15,2] ,"@E 999999")+"     "+Transform(aEmpr3[15,1] ,"@E 999999")+"   "+STR0117,"053"})//Mais de 1 ate 2 Anos
aAdd( aLogProc, {"1",Transform(aEmpr3[16,2] ,"@E 999999")+"     "+Transform(aEmpr3[16,1] ,"@E 999999")+"   "+STR0118,"054"})//Mais de 2 ate 5 Anos
aAdd( aLogProc, {"1",Transform(aEmpr3[17,2] ,"@E 999999")+"     "+Transform(aEmpr3[17,1] ,"@E 999999")+"   "+STR0119,"055"})//Mais de 5 ate 10 Anos
aAdd( aLogProc, {"1",Transform(aEmpr3[18,2] ,"@E 999999")+"     "+Transform(aEmpr3[18,1] ,"@E 999999")+"   "+STR0120,"056"})//Mais de 10 ate 15 Anos
aAdd( aLogProc, {"1",Transform(aEmpr3[19,2] ,"@E 999999")+"     "+Transform(aEmpr3[19,1] ,"@E 999999")+"   "+STR0121,"057"})//Mais de 15 Anos
//Trabalhadores Estrangeiros
aAdd( aLogProc, {"1",Replicate("-",130),"058"})
aAdd( aLogProc, {"1",STR0084,"058"} )//"1.6 - Trabalhadores Estrangeiros"
aAdd( aLogProc, {"1",STR0102,"059"})//"Homem   Mulheres"
aAdd( aLogProc, {"1",Replicate("-",130),"060"})
aAdd( aLogProc, {"1",Transform(aEmpr3[20,2] ,"@E 999999")+"     "+Transform(aEmpr3[20,1] ,"@E 999999")+"   "+STR0122,"061"})//Paises da Uniao Europeia
aAdd( aLogProc, {"1",Transform(aEmpr3[21,2] ,"@E 999999")+"     "+Transform(aEmpr3[21,1] ,"@E 999999")+"   "+STR0123,"062"})//Paises Africanos da Lingua Oficial portuguesa
aAdd( aLogProc, {"1",Transform(aEmpr3[22,2] ,"@E 999999")+"     "+Transform(aEmpr3[22,1] ,"@E 999999")+"   "+STR0124,"063"})//Brasil
aAdd( aLogProc, {"1",Transform(aEmpr3[23,2] ,"@E 999999")+"     "+Transform(aEmpr3[23,1] ,"@E 999999")+"   "+STR0125,"064"})//Outros Paises
//Trabalhadores Deficientes
aAdd( aLogProc, {"1",Replicate("-",130),"065"})
aAdd( aLogProc, {"1",STR0085,"066"} )//"1.7 - Trabalhadores Deficientes"
aAdd( aLogProc, {"1",STR0102,"067"}) //"Homem   Mulheres"
aAdd( aLogProc, {"1",Transform(aEmpr3[24,2] ,"@E 999999")+"     "+Transform(aEmpr3[24,1] ,"@E 999999")+"   "+STR0126,"068"})//Deficientes
//Estrutura de Niveis de Habilitação do pessoal ao servico em 31 de dezembro
aAdd( aLogProc, {"1",Replicate("-",130),"069"})
aAdd( aLogProc, {"1",STR0086,"070"} )//"1.8 - Estrutura de Niveis de Habilitação do pessoal ao servico em 31 de dezembro"
aAdd( aLogProc, {"1",STR0102,"071"})//"Homem   Mulheres"
aAdd( aLogProc, {"1",Transform(aEmpr3[25,2] ,"@E 999999")+"     "+Transform(aEmpr3[25,1] ,"@E 999999")+"   "+STR0127,"072"})//Inferior ao 1 ciclo do ensino basico
aAdd( aLogProc, {"1",Transform(aEmpr3[26,2] ,"@E 999999")+"     "+Transform(aEmpr3[26,1] ,"@E 999999")+"   "+STR0128,"073"})//1 Ciclo de ensino basico
aAdd( aLogProc, {"1",Transform(aEmpr3[27,2] ,"@E 999999")+"     "+Transform(aEmpr3[27,1] ,"@E 999999")+"   "+STR0129,"074"})//2 Ciclo de ensino basico
aAdd( aLogProc, {"1",Transform(aEmpr3[28,2] ,"@E 999999")+"     "+Transform(aEmpr3[28,1] ,"@E 999999")+"   "+STR0130,"075"})//3 Ciclo de ensino basico
aAdd( aLogProc, {"1",Transform(aEmpr3[29,2] ,"@E 999999")+"     "+Transform(aEmpr3[29,1] ,"@E 999999")+"   "+STR0131,"076"})//Ensino Secundario
aAdd( aLogProc, {"1",Transform(aEmpr3[30,2] ,"@E 999999")+"     "+Transform(aEmpr3[30,1] ,"@E 999999")+"   "+STR0132,"077"})//Ensino Superior de Indole Profissional
aAdd( aLogProc, {"1",Transform(aEmpr3[31,2] ,"@E 999999")+"     "+Transform(aEmpr3[31,1] ,"@E 999999")+"   "+STR0133,"078"})//Ensino Superior Politecnico
aAdd( aLogProc, {"1",Transform(aEmpr3[32,2] ,"@E 999999")+"     "+Transform(aEmpr3[32,1] ,"@E 999999")+"   "+STR0134,"079"})//Ensino superior Universitario
aAdd( aLogProc, {"1",Transform(aEmpr3[33,2] ,"@E 999999")+"     "+Transform(aEmpr3[33,1] ,"@E 999999")+"   "+STR0135,"080"})//Outros
//CONTRATADOS A TERMO
aAdd( aLogProc, {"1",Replicate("-",130),"081"})
aAdd( aLogProc, {"1",STR0087,"082"} )//"1.9 - Contratados a Termo"
aAdd( aLogProc, {"1",Space(10)+Replicate("-",120),"083"})
//Item 1.9.1 - Contratos a Termo Certo (Contratos a Termo)
aAdd( aLogProc, {"1",Space(10)+STR0088,"084"} )//"1.9.1 - Contratos a Termo Certo"
aAdd( aLogProc, {"1",Space(10)+STR0102,"085"})//"Homem   Mulheres"
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[6,2,2],"@E 999999")+"     "+Transform(aEmpr1[6,1,2],"@E 999999")+"   "+STR0136,"086"})//Quadro Superiores
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[6,2,3],"@E 999999")+"     "+Transform(aEmpr1[6,1,3],"@E 999999")+"   "+STR0137,"087"})//Quadro Medios
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[6,2,4],"@E 999999")+"     "+Transform(aEmpr1[6,1,4],"@E 999999")+"   "+STR0138,"088"})//Quadro Intermediarios
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[6,2,5],"@E 999999")+"     "+Transform(aEmpr1[6,1,5],"@E 999999")+"   "+STR0139,"089"})//Profissionais altamente qualificados e qualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[6,2,6],"@E 999999")+"     "+Transform(aEmpr1[6,1,6],"@E 999999")+"   "+STR0140,"090"})//Profissionais semiqualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[6,2,7],"@E 999999")+"     "+Transform(aEmpr1[6,1,7],"@E 999999")+"   "+STR0141,"091"})//Profissionais semiqualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[6,2,8],"@E 999999")+"     "+Transform(aEmpr1[6,1,8],"@E 999999")+"   "+STR0142,"092"})//Praticantes\Aprendizes
aAdd( aLogProc, {"1",Space(10)+Replicate("-",120),"093"})
//Item 1.9.2 - Contratos a Termo InCerto(Contratos a Termo)
aAdd( aLogProc, {"1",Space(10)+STR0089,"094"} )//"1.9.2 - Contratos a Termo InCerto"
aAdd( aLogProc, {"1",Space(10)+STR0102,"095"})//"Homem   Mulheres"
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[7,2,2],"@E 999999")+"     "+Transform(aEmpr1[7,1,2],"@E 999999")+"   "+STR0136,"096"}) //Quadro Superiores
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[7,2,3],"@E 999999")+"     "+Transform(aEmpr1[7,1,3],"@E 999999")+"   "+STR0137,"097"})//Quadro Medios
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[7,2,4],"@E 999999")+"     "+Transform(aEmpr1[7,1,4],"@E 999999")+"   "+STR0138,"098"})//Quadro Intermediarios
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[7,2,5],"@E 999999")+"     "+Transform(aEmpr1[7,1,5],"@E 999999")+"   "+STR0139,"099"})//Profissionais altamente qualificados e qualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[7,2,6],"@E 999999")+"     "+Transform(aEmpr1[7,1,6],"@E 999999")+"   "+STR0140,"100"})//Profissionais semiqualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[7,2,7],"@E 999999")+"     "+Transform(aEmpr1[7,1,7],"@E 999999")+"   "+STR0141,"101"})//Profissionais nao qualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[7,2,8],"@E 999999")+"     "+Transform(aEmpr1[7,1,8],"@E 999999")+"   "+STR0142,"102"})//Praticantes\Aprendizes
aAdd( aLogProc, {"1",Space(10)+Replicate("-",120),"103"})
//Item 1.9.3 - Contratados a Termo que passaram ao Q.Permanente(Contratos a Termo)
aAdd( aLogProc, {"1",Space(10)+STR0090,"104"} )//"1.9.3 - Contratados a Termo que passaram ao Q.Permanente"
aAdd( aLogProc, {"1",Space(10)+STR0102,"105"})//"Homem   Mulheres"
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[8,2,2],"@E 999999")+"     "+Transform(aEmpr1[8,1,2],"@E 999999")+"   "+STR0136,"106"})//Quadro Superiores
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[8,2,3],"@E 999999")+"     "+Transform(aEmpr1[8,1,3],"@E 999999")+"   "+STR0137,"107"})//Quadro Medios
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[8,2,4],"@E 999999")+"     "+Transform(aEmpr1[8,1,4],"@E 999999")+"   "+STR0138,"108"})//Quadro Intermediarios
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[8,2,5],"@E 999999")+"     "+Transform(aEmpr1[8,1,5],"@E 999999")+"   "+STR0139,"109"})//Profissionais altamente qualificados e qualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[8,2,6],"@E 999999")+"     "+Transform(aEmpr1[8,1,6],"@E 999999")+"   "+STR0140,"110"})//Profissionais semiqualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[8,2,7],"@E 999999")+"     "+Transform(aEmpr1[8,1,7],"@E 999999")+"   "+STR0141,"111"})//Profissionais nao qualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[8,2,8],"@E 999999")+"     "+Transform(aEmpr1[8,1,8],"@E 999999")+"   "+STR0142,"112"})//Praticantes\Aprendizes
//Item 1.9.4 - Contratados a termo que transitaram do ano anterior (Contratos a Termo)
aAdd( aLogProc, {"1",Space(10)+Replicate("-",120),"113"})
aAdd( aLogProc, {"1",Space(10)+STR0091,"114"} )//"1.9.4 - Contratados a termo que transitaram do ano anterior"
aAdd( aLogProc, {"1",Space(10)+STR0102,"115"})//"Homem   Mulheres"
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[9,2,2],"@E 999999")+"     "+Transform(aEmpr1[9,1,2],"@E 999999")+"   "+STR0136,"116"})//Quadro Superiores
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[9,2,3],"@E 999999")+"     "+Transform(aEmpr1[9,1,3],"@E 999999")+"   "+STR0137,"117"})//Quadro Medios
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[9,2,4],"@E 999999")+"     "+Transform(aEmpr1[9,1,4],"@E 999999")+"   "+STR0138,"118"})//Quadro Intermediarios
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[9,2,5],"@E 999999")+"     "+Transform(aEmpr1[9,1,5],"@E 999999")+"   "+STR0139,"119"})//Profissionais altamente qualificados e qualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[9,2,6],"@E 999999")+"     "+Transform(aEmpr1[9,1,6],"@E 999999")+"   "+STR0140,"120"})//Profissionais semiqualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[9,2,7],"@E 999999")+"     "+Transform(aEmpr1[9,1,7],"@E 999999")+"   "+STR0141,"121"})//Profissionais nao qualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[9,2,8],"@E 999999")+"     "+Transform(aEmpr1[9,1,8],"@E 999999")+"   "+STR0142,"122"})//Praticantes\Aprendizes
//Item 1.9.5 - Numero Medio de contratados (Contratos a Termo)
aAdd( aLogProc, {"1",Space(10)+Replicate("-",120),"123"})
aAdd( aLogProc, {"1",Space(10)+STR0092,"124"} )//"1.9.5 - Numero Medio de contratados"
aAdd( aLogProc, {"1",Space(10)+STR0102,"125"})//"Homem   Mulheres"
aAdd( aLogProc, {"1",Space(10)+Transform(nMedM2,"@E 999999")+"     "+Transform(nMedF2,"@E 999999")+"   "+STR0136,"126"})//Quadro Superiores
aAdd( aLogProc, {"1",Space(10)+Transform(nMedM3,"@E 999999")+"     "+Transform(nMedF3,"@E 999999")+"   "+STR0137,"127"})//Quadro Medios
aAdd( aLogProc, {"1",Space(10)+Transform(nMedM4,"@E 999999")+"     "+Transform(nMedF4,"@E 999999")+"   "+STR0138,"128"})//Quadro Intermediarios
aAdd( aLogProc, {"1",Space(10)+Transform(nMedM5,"@E 999999")+"     "+Transform(nMedF5,"@E 999999")+"   "+STR0139,"129"})//Profissionais altamente qualificados e qualificados
aAdd( aLogProc, {"1",Space(10)+Transform(nMedM6,"@E 999999")+"     "+Transform(nMedF6,"@E 999999")+"   "+STR0140,"130"})//Profissionais semiqualificados
aAdd( aLogProc, {"1",Space(10)+Transform(nMedM7,"@E 999999")+"     "+Transform(nMedF7,"@E 999999")+"   "+STR0141,"131"})//Profissionais nao qualificados
aAdd( aLogProc, {"1",Space(10)+Transform(nMedM8,"@E 999999")+"     "+Transform(nMedF8,"@E 999999")+"   "+STR0142,"132"})//Praticantes\Aprendizes

//MOVIMENTOS DE SAIDAS
aAdd( aLogProc, {"1",Replicate("-",130),"133"})
aAdd( aLogProc, {"1",STR0093,"134"} )//"1.10 - Movimentos de Saidas"
//Item 1.10.1 - Saida de Pessoal com Contrato Permanente(Movimento de Saida)
aAdd( aLogProc, {"1",Space(10)+Replicate("-",120),"135"})
aAdd( aLogProc, {"1",Space(10)+STR0094,"136"} )//"1.10.1 - Saida de Pessoal com Contrato Permanente"
aAdd( aLogProc, {"1",Space(10)+STR0102,"137"})//"Homem   Mulheres"
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[10,2,2],"@E 999999")+"     "+Transform(aEmpr1[10,1,2],"@E 999999")+"   "+STR0136,"138"})//Quadro Superiores
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[10,2,3],"@E 999999")+"     "+Transform(aEmpr1[10,1,3],"@E 999999")+"   "+STR0137,"139"})//Quadro Medios
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[10,2,4],"@E 999999")+"     "+Transform(aEmpr1[10,1,4],"@E 999999")+"   "+STR0138,"140"})//Quadro Intermediarios
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[10,2,5],"@E 999999")+"     "+Transform(aEmpr1[10,1,5],"@E 999999")+"   "+STR0139,"141"})//Profissionais altamente qualificados e qualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[10,2,6],"@E 999999")+"     "+Transform(aEmpr1[10,1,6],"@E 999999")+"   "+STR0140,"142"})//Profissionais semiqualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[10,2,7],"@E 999999")+"     "+Transform(aEmpr1[10,1,7],"@E 999999")+"   "+STR0141,"143"})//Profissionais nao qualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[10,2,8],"@E 999999")+"     "+Transform(aEmpr1[10,1,8],"@E 999999")+"   "+STR0142,"144"})//Praticantes\Aprendizes
//Item 1.10.2 - Saida de Pessoal com Contrato Termo Certo e Incerto(Movimento de Saida)
aAdd( aLogProc, {"1",Space(10)+Replicate("-",120),"145"})
aAdd( aLogProc, {"1",Space(10)+STR0095,"146"} )//"1.10.2 - Saida de Pessoal com Contrato Termo Certo e Incerto"
aAdd( aLogProc, {"1",Space(10)+STR0102,"147"})//"Homem   Mulheres"
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[11,2,2],"@E 999999")+"     "+Transform(aEmpr1[11,1,2],"@E 999999")+"   "+STR0136,"148"})//Quadro Superiores
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[11,2,3],"@E 999999")+"     "+Transform(aEmpr1[11,1,3],"@E 999999")+"   "+STR0137,"149"})//Quadro Medios
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[11,2,4],"@E 999999")+"     "+Transform(aEmpr1[11,1,4],"@E 999999")+"   "+STR0138,"150"})//Quadro Intermediarios
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[11,2,5],"@E 999999")+"     "+Transform(aEmpr1[11,1,5],"@E 999999")+"   "+STR0139,"151"})//Profissionais altamente qualificados e qualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[11,2,6],"@E 999999")+"     "+Transform(aEmpr1[11,1,6],"@E 999999")+"   "+STR0140,"152"})//Profissionais semiqualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[11,2,7],"@E 999999")+"     "+Transform(aEmpr1[11,1,7],"@E 999999")+"   "+STR0141,"153"})//Profissionais nao qualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[11,2,8],"@E 999999")+"     "+Transform(aEmpr1[11,1,8],"@E 999999")+"   "+STR0142,"154"})//Praticantes\Aprendizes
//Item 1.10.3 - Saida de Outros Trabalhadores(Movimento de Saida)
aAdd( aLogProc, {"1",Space(10)+Replicate("-",120),"155"})
aAdd( aLogProc, {"1",Space(10)+STR0096,"156"} )//"1.10.3 - Saida de Outros Trabalhadores"
aAdd( aLogProc, {"1",Space(10)+STR0102,"157"})//"Homem   Mulheres"
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[12,2,2],"@E 999999")+"     "+Transform(aEmpr1[12,1,2],"@E 999999")+"   "+STR0136,"158"})//Quadro Superiores
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[12,2,3],"@E 999999")+"     "+Transform(aEmpr1[12,1,3],"@E 999999")+"   "+STR0137,"159"})//Quadro Medios
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[12,2,4],"@E 999999")+"     "+Transform(aEmpr1[12,1,4],"@E 999999")+"   "+STR0138,"160"})//Quadro Intermediarios
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[12,2,5],"@E 999999")+"     "+Transform(aEmpr1[12,1,5],"@E 999999")+"   "+STR0139,"161"})//Profissionais altamente qualificados e qualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[12,2,6],"@E 999999")+"     "+Transform(aEmpr1[12,1,6],"@E 999999")+"   "+STR0140,"162"})//Profissionais semiqualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[12,2,7],"@E 999999")+"     "+Transform(aEmpr1[12,1,7],"@E 999999")+"   "+STR0141,"163"})//Profissionais nao qualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[12,2,8],"@E 999999")+"     "+Transform(aEmpr1[12,1,8],"@E 999999")+"   "+STR0142,"164"})//Praticantes\Aprendizes
//Promocoes
aAdd( aLogProc, {"1",Replicate("-",130),"206"})
aAdd( aLogProc, {"1",STR0097,"207"} )//"1.15 - Promocoes"
//Item 1.15.1 - Antiguidade(Promocoes)
aAdd( aLogProc, {"1",Space(10)+Replicate("-",120),"208"})
aAdd( aLogProc, {"1",Space(10)+STR0098,"209"} )//"1.15.1 - Antiguidade"
aAdd( aLogProc, {"1",Space(10)+STR0102,"210"})//"Homem   Mulheres"
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[13,2,2],"@E 999999")+"     "+Transform(aEmpr1[13,1,2],"@E 999999")+"   "+STR0136,"211"})//Quadro Superiores
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[13,2,3],"@E 999999")+"     "+Transform(aEmpr1[13,1,3],"@E 999999")+"   "+STR0137,"212"})//Quadro Medios
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[13,2,4],"@E 999999")+"     "+Transform(aEmpr1[13,1,4],"@E 999999")+"   "+STR0138,"213"})//Quadro Intermediarios
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[13,2,5],"@E 999999")+"     "+Transform(aEmpr1[13,1,5],"@E 999999")+"   "+STR0139,"214"})//Profissionais altamente qualificados e qualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[13,2,6],"@E 999999")+"     "+Transform(aEmpr1[13,1,6],"@E 999999")+"   "+STR0140,"215"})//Profissionais semiqualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[13,2,7],"@E 999999")+"     "+Transform(aEmpr1[13,1,7],"@E 999999")+"   "+STR0141,"216"})//Profissionais nao qualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[13,2,8],"@E 999999")+"     "+Transform(aEmpr1[13,1,8],"@E 999999")+"   "+STR0142,"217"})//Praticantes\Aprendizes
//Item 1.15.2 - Merito(Promocoes)
aAdd( aLogProc, {"1",Space(10)+Replicate("-",120),"218"})
aAdd( aLogProc, {"1",Space(10)+STR0099,"219"} )//"1.15.2 - Merito"
aAdd( aLogProc, {"1",Space(10)+STR0102,"220"})//"Homem   Mulheres"
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[14,2,2],"@E 999999")+"     "+Transform(aEmpr1[14,1,2],"@E 999999")+"   "+STR0136,"221"})//Quadro Superiores
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[14,2,3],"@E 999999")+"     "+Transform(aEmpr1[14,1,3],"@E 999999")+"   "+STR0137,"222"})//Quadro Medios
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[14,2,4],"@E 999999")+"     "+Transform(aEmpr1[14,1,4],"@E 999999")+"   "+STR0138,"223"})//Quadro Intermediarios
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[14,2,5],"@E 999999")+"     "+Transform(aEmpr1[14,1,5],"@E 999999")+"   "+STR0139,"224"})//Profissionais altamente qualificados e qualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[14,2,6],"@E 999999")+"     "+Transform(aEmpr1[14,1,6],"@E 999999")+"   "+STR0140,"235"})//Profissionais semiqualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[14,2,7],"@E 999999")+"     "+Transform(aEmpr1[14,1,7],"@E 999999")+"   "+STR0141,"236"})//Profissionais nao qualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[14,2,8],"@E 999999")+"     "+Transform(aEmpr1[14,1,8],"@E 999999")+"   "+STR0142,"237"})//Praticantes\Aprendizes
//Item 1.15.3 - Outros(Promocoes)                    
aAdd( aLogProc, {"1",Space(10)+Replicate("-",120),"228"})
aAdd( aLogProc, {"1",Space(10)+STR0100,"229"} )//"1.15.3 - Outros"
aAdd( aLogProc, {"1",Space(10)+STR0102,"230"})//"Homem   Mulheres"
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[15,2,2],"@E 999999")+"     "+Transform(aEmpr1[15,1,2],"@E 999999")+"   "+STR0136,"231"})//Quadro Superiores
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[15,2,3],"@E 999999")+"     "+Transform(aEmpr1[15,1,3],"@E 999999")+"   "+STR0137,"232"})//Quadro Medios
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[15,2,4],"@E 999999")+"     "+Transform(aEmpr1[15,1,4],"@E 999999")+"   "+STR0138,"233"})//Quadro Intermediarios
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[15,2,5],"@E 999999")+"     "+Transform(aEmpr1[15,1,5],"@E 999999")+"   "+STR0139,"234"})//Profissionais altamente qualificados e qualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[15,2,6],"@E 999999")+"     "+Transform(aEmpr1[15,1,6],"@E 999999")+"   "+STR0140,"235"})//Profissionais semiqualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[15,2,7],"@E 999999")+"     "+Transform(aEmpr1[15,1,7],"@E 999999")+"   "+STR0141,"236"})//Profissionais nao qualificados
aAdd( aLogProc, {"1",Space(10)+Transform(aEmpr1[15,2,8],"@E 999999")+"     "+Transform(aEmpr1[15,1,8],"@E 999999")+"   "+STR0142,"237"})//Praticantes\Aprendizes
//1.16 - RECONVERSOES/RECLASSIFICACOES
aAdd( aLogProc, {"1",Replicate("-",120),"238"})
aAdd( aLogProc, {"1",STR0101,"239"} )//"1.16 - Reconversoes/Reclassificacoes"
aAdd( aLogProc, {"1",STR0102,"240"})//"Homem   Mulheres"
aAdd( aLogProc, {"1",Transform(aEmpr1[16,2,2],"@E 999999")+"     "+Transform(aEmpr1[16,1,2],"@E 999999")+"   "+STR0136,"241"})//Quadro Superiores
aAdd( aLogProc, {"1",Transform(aEmpr1[16,2,3],"@E 999999")+"     "+Transform(aEmpr1[16,1,3],"@E 999999")+"   "+STR0137,"242"})//Quadro Medios
aAdd( aLogProc, {"1",Transform(aEmpr1[16,2,4],"@E 999999")+"     "+Transform(aEmpr1[16,1,4],"@E 999999")+"   "+STR0138,"243"})//Quadro Intermediarios
aAdd( aLogProc, {"1",Transform(aEmpr1[16,2,5],"@E 999999")+"     "+Transform(aEmpr1[16,1,5],"@E 999999")+"   "+STR0139,"244"})//Profissionais altamente qualificados e qualificados
aAdd( aLogProc, {"1",Transform(aEmpr1[16,2,6],"@E 999999")+"     "+Transform(aEmpr1[16,1,6],"@E 999999")+"   "+STR0140,"245"})//Profissionais semiqualificados
aAdd( aLogProc, {"1",Transform(aEmpr1[16,2,7],"@E 999999")+"     "+Transform(aEmpr1[16,1,7],"@E 999999")+"   "+STR0141,"246"})//Profissionais nao qualificados
aAdd( aLogProc, {"1",Transform(aEmpr1[16,2,8],"@E 999999")+"     "+Transform(aEmpr1[16,1,8],"@E 999999")+"   "+STR0142,"247"})//Praticantes\Aprendizes*/




Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CusPesBS ³ Autor ³ Marcos Kato		      ³ Data ³   25.07.08    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Custo Pessoal - Balanco Social								     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Portugal                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³           ³											 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CusPesBS() 
Local cQryCusP:=""
Local aCustPes:={}
Local nSalLiq:=0,nSalMai:=0,nSalMen:=0,nSalInt:=0,nQtdFun:=0,nQtdMai:=0,nQtdMen:=0
Local nSalBasO:=0,nSubRegO:=0,nSubIrrO:=0,nPagGenO:=0,nEncargO:=0,nCustCSO:=0,nCustFPO:=0,nCustPEO:=0
Local nSalBasR:=0,nSubRegR:=0,nSubIrrR:=0,nPagGenR:=0,nEncargR:=0,nCustCSR:=0,nCustFPR:=0,nCustPER:=0

cQrYCusP:=" SELECT RGQ_STAITE,RGQ_TIPITE,SUM(CT2_VALOR) CT2_VALOR "
cQrYCusP+=" FROM "+RetSqlName("RGQ")+" RGQ "
cQrYCusP+=" INNER JOIN "+RetSqlName("CT2")+" CT2 ON "
cQrYCusP+=" RGQ_CODIGO=CT2_DEBITO "     
cQrYCusP+=" AND SUBSTRING(CT2_DATA,1,4)='"+cParAnoBas+"' "
cQrYCusP+=" AND CT2.D_E_L_E_T_='' "
cQrYCusP+=" WHERE RGQ.D_E_L_E_T_='' "
cQrYCusP+=" AND RGQ_FILIAL IN ('"+cParFilial+"','"+space(FWGETTAMFILIAL)+"') "
cQrYCusP+=" AND RGQ_ITEM='P' "
cQrYCusP+=" GROUP BY RGQ_STAITE,RGQ_TIPITE "


cQrYCusP := ChangeQuery(cQrYCusP)

If Select("TRBCUSP")>0
	DbSelectArea("TRBCUSP")
	TRBCUSP->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryCusP),"TRBCUSP",.F.,.T.)

DbSelectArea("TRBCUSP")
TRBCUSP->(dbGoTop()) 
//1 - Salário base
//2 - Subsídios e prêmios regulares
//3 - Subsídios e prêmios irregulares
//4 - Pagamentos em gêneros
//5 - Encargos legais
//6 - Outros custos de caráter social
//7 - Custo com a formação profissional
//8 - Outros custos com o pessoal
aAdd( aLogProc, {"2",Replicate("*",130),"000"} )
aAdd( aLogProc, {"2",STR0143,"001"} )   //"CUSTO PESSOAL"
aAdd( aLogProc, {"2",Replicate("*",130),"002"} )

If TRBCUSP->(!Eof())         
	Do While TRBCUSP->(!Eof())
		If TRBCUSP->RGQ_STAITE$"13"//Orgao Sociais
			If TRBCUSP->RGQ_TIPITE=="1" 	
			//2.1.1 - Salario Base
				nSalBasO:=TRBCUSP->CT2_VALOR
			ElseIf TRBCUSP->RGQ_TIPITE=="2" 	
			//2.1.2 - Subsidios e premios regulares
				nSubRegO:=TRBCUSP->CT2_VALOR		
			ElseIf TRBCUSP->RGQ_TIPITE=="3" 	
			//Item 2.2  - Subsidios e premios irregulares
				nSubIrrO:=TRBCUSP->CT2_VALOR		
			ElseIf TRBCUSP->RGQ_TIPITE=="4" 	
			//Item 2.3  - Pagamento em Gêneros     
				nPagGenO:=TRBCUSP->CT2_VALOR		
			ElseIf TRBCUSP->RGQ_TIPITE=="5" 	
			//Item 2.4  - Encargos Legais, Convencionais e Facultativos
				nEncargO:=TRBCUSP->CT2_VALOR		
			ElseIf TRBCUSP->RGQ_TIPITE=="6"
			//Item 2.5  - Outros Custos de caracter social
				nCustCSO:=TRBCUSP->CT2_VALOR		
			ElseIf TRBCUSP->RGQ_TIPITE=="7" 	
			//Item 2.6  - Custos com formação profissional
				nCustFPO:=TRBCUSP->CT2_VALOR
			ElseIf TRBCUSP->RGQ_TIPITE=="8" 	
			//Item 2.7  - Outros custos com o Pessoal
				nCustPeO:=TRBCUSP->CT2_VALOR		
			Endif 	
		Endif	
		If TRBCUSP->RGQ_STAITE$"23"//Restantes Trabalhadores
			If TRBCUSP->RGQ_TIPITE=="1" 	
			//2.1.1 - Salario Base
				nSalBasR:=TRBCUSP->CT2_VALOR
			ElseIf TRBCUSP->RGQ_TIPITE=="2" 	
			//2.1.2 - Subsidios e premios regulares
				nSubRegR:=TRBCUSP->CT2_VALOR		
			ElseIf TRBCUSP->RGQ_TIPITE=="3" 	
			//Item 2.2  - Subsidios e premios irregulares
				nSubIrrR:=TRBCUSP->CT2_VALOR		
			ElseIf TRBCUSP->RGQ_TIPITE=="4" 	
			//Item 2.3  - Pagamento em Gêneros     
				nPagGenR:=TRBCUSP->CT2_VALOR		
			ElseIf TRBCUSP->RGQ_TIPITE=="5" 	
			//Item 2.4  - Encargos Legais, Convencionais e Facultativos
				nEncargR:=TRBCUSP->CT2_VALOR		
			ElseIf TRBCUSP->RGQ_TIPITE=="6"
			//Item 2.5  - Outros Custos de caracter social
				nCustCSR:=TRBCUSP->CT2_VALOR		
			ElseIf TRBCUSP->RGQ_TIPITE=="7" 	
			//Item 2.6  - Custos com formação profissional
				nCustFPR:=TRBCUSP->CT2_VALOR
			ElseIf TRBCUSP->RGQ_TIPITE=="8" 	
			//Item 2.7  - Outros custos com o Pessoal
				nCustPeR:=TRBCUSP->CT2_VALOR		
			Endif 			
		Endif
		TRBCUSP->(DbSkip())
	End                         
	
	Aadd(aCustPes,{"C","2.1"  ," "," "," "," "," ",0,0,nSalBasO+nSubRegO,nSalBasR+nSubRegR})//Salario Direto
	Aadd(aCustPes,{"C","2.1.1"," "," "," "," "," ",0,0,nSalBasO         ,nSalBasR})//Salario Base
	Aadd(aCustPes,{"C","2.1.2"," "," "," "," "," ",0,0,nSubRegO         ,nSubRegR})//Subsidio e premios regular
	Aadd(aCustPes,{"C","2.2"  ," "," "," "," "," ",0,0,nSubIrrO         ,nSubIrrR})//Subsidio e premios irregulares
	Aadd(aCustPes,{"C","2.3"  ," "," "," "," "," ",0,0,nPagGenO         ,nPagGenR})//Pagamento Generos    
	Aadd(aCustPes,{"C","2.4"  ," "," "," "," "," ",0,0,nEncargO         ,nEncargR})//Encargos
	Aadd(aCustPes,{"C","2.5"  ," "," "," "," "," ",0,0,nCustCSO         ,nCustCSR})//Custo de carater social
	Aadd(aCustPes,{"C","2.6"  ," "," "," "," "," ",0,0,nCustFPO         ,nCustFPR})//Custo com formacao profissional
	Aadd(aCustPes,{"C","2.7"  ," "," "," "," "," ",0,0,nCustPEO         ,nCustPER})//Outros custo pessoal  

	aAdd( aLogProc, {"2"," 	                                   "+STR0144+"    "+STR0145,"003"} )//Orgaos Sociais#Restantes Trabalhadores
	aAdd( aLogProc, {"2",STR0145+Transform(nSalBasO+nSubRegO,"@E 999,999,999.99")+'    '+Transform(nSalBasR+nSubRegR,"@E 999,999,999.99"),"004"} )//"2.1 - Salario Direto                          "
	aAdd( aLogProc, {"2",STR0146+Transform(nSalBasO         ,"@E 999,999,999.99")+'    '+Transform(nSalBasR         ,"@E 999,999,999.99"),"005"} )//"          2.1.1 - Salario Base                "
	aAdd( aLogProc, {"2",STR0147+Transform(nSubRegO         ,"@E 999,999,999.99")+'    '+Transform(nSubRegR         ,"@E 999,999,999.99"),"006"} )//"          2.1.2 - Subsidio e premio regular   "
	aAdd( aLogProc, {"2",STR0148+Transform(nSubIrrO         ,"@E 999,999,999.99")+'    '+Transform(nSubIrrR         ,"@E 999,999,999.99"),"007"} )//"2.2 - Subsidio e premio irregular             "
	aAdd( aLogProc, {"2",STR0149+Transform(nPagGenO		    ,"@E 999,999,999.99")+'    '+Transform(nPagGenR         ,"@E 999,999,999.99"),"008"} )//"2.3 - Pagamento em Genero                     "
	aAdd( aLogProc, {"2",STR0150+Transform(nEncargO         ,"@E 999,999,999.99")+'    '+Transform(nEncargR         ,"@E 999,999,999.99"),"009"} )//"2.4 - Encargos                                "
	aAdd( aLogProc, {"2",STR0151+Transform(nCustCSO         ,"@E 999,999,999.99")+'    '+Transform(nCustCSR         ,"@E 999,999,999.99"),"010"} )//"2.5 - Custo de Carater Social                 "
	aAdd( aLogProc, {"2",STR0153+Transform(nCustFPO         ,"@E 999,999,999.99")+'    '+Transform(nCustFPR         ,"@E 999,999,999.99"),"011"} )//"2.6 - Custo com Formacao Profissional         "
	aAdd( aLogProc, {"2",STR0154+Transform(nCustPEO         ,"@E 999,999,999.99")+'    '+Transform(nCustPER         ,"@E 999,999,999.99"),"012"} )//"2.7 - Outros Custo Pessoal                    "

		
Endif
//Item 2.9  - Leque salarial Liquido      
cQryLeq:=" SELECT COUNT(*) QTDFUN, "
cQryLeq+=" CASE WHEN MIN(RA_SALARIO)=0 THEN MAX(RA_SALARIO)/1 ELSE MAX(RA_SALARIO)/MIN(RA_SALARIO) END SALLIQ "
cQryLeq+=" FROM "+RetSqlName("SRA")+" SRA "
cQryLeq+=" INNER JOIN "+RetSqlName("RGG")+"  RGG ON "
cQryLeq+=" RGG_FILIAL=RA_FILIAL "
cQryLeq+=" AND RGG_CODIRC=RA_CODIRCT "
cQryLeq+=" AND RGG_CODIGO=RA_CODCAT "
cQryLeq+=" AND RGG.D_E_L_E_T_='' "
cQryLeq+=" WHERE SRA.D_E_L_E_T_='' "
cQryLeq+=" AND RA_FILIAL='"+cParFilial+"' "
cQryLeq+=" AND( RA_ADMISSA <= '"+cParAnoBas+"1231' AND RA_DEMISSA = '' ) "
cQryLeq+=" OR ( RA_DEMISSA >= '"+cParAnoBas+"0101' AND RA_DEMISSA <= '"+cParAnoBas+"1231') "
cQryLeq+=" AND RA_TIPOCO<>'' "
cQryLeq := ChangeQuery(cQryLeq)

If Select("LEQSAL")>0
	DbSelectArea("LEQSAL")
	LEQSAL->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryLeq),"LEQSAL",.F.,.T.)

DbSelectArea("LEQSAL")
LEQSAL->(dbGoTop()) 
If LEQSAL->(!Eof())         
	nSaliq:=LEQSAL->SALLIQ
	nQtdFun:=round((LEQSAL->QTDFUN/100)*5,0)
	
	If nQtdFun>0       
		//Retira os 5% dos funcionarios que recebem o maior salario
		cQryMai:=" SELECT RA_SALARIO "
		cQryMai+=" FROM "+RetSqlName("SRA")+" SRA "
		cQryMai+=" INNER JOIN "+RetSqlName("RGG")+"  RGG ON "
		cQryMai+=" RGG_FILIAL=RA_FILIAL "
		cQryMai+=" AND RGG_CODIRC=RA_CODIRCT "
		cQryMai+=" AND RGG_CODIGO=RA_CODCAT "
		cQryMai+=" AND RGG.D_E_L_E_T_='' "
		cQryMai+=" WHERE SRA.D_E_L_E_T_='' "
		cQryMai+=" AND RA_FILIAL='"+cParFilial+"' "		
		cQryMai+=" AND(RA_ADMISSA <= '"+cParAnoBas+"1231' AND RA_DEMISSA='') "
		cQryMai+=" OR  (RA_DEMISSA >= '"+cParAnoBas+"0101' AND RA_DEMISSA <= '"+cParAnoBas+"1231') "
		cQryMai+=" AND RA_TIPOCO<>'' "
		cQryMai+=" WHERE SRA.D_E_L_E_T_='' "  
		cQryMai+=" ORDER BY RA_SALARIO DESC "		
		cQryMai:= ChangeQuery(cQryMai)
		If Select("LEQMAI")>0
			DbSelectArea("LEQMAI")
			LEQSAL->(DbCloseArea())
		Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryLeq),"LEQMAI",.F.,.T.)
		DbSelectArea("LEQMAI")
		LEQMAI->(dbGoTop()) 
		If LEQMAI->(!Eof())
		   nQtdMen:=1
		   Do While LEQMAI->(!Eof()) 
		    	If nQtdMai>nQtdFun
		            nSalMai:=LEQMAI->RA_SALARIO
		   			Exit
		        Endif
				LEQMAI->(DbSkip())   		     
		   End
		Endif         
		//Retira os 5% dos funcionarios que recebem o menor salario	
		cQryMen:=" SELECT RA_SALARIO "
		cQryMen+=" FROM "+RetSqlName("SRA")+" SRA "
		cQryMen+=" INNER JOIN "+RetSqlName("RGG")+"  RGG ON "
		cQryMen+=" RGG_FILIAL=RA_FILIAL "
		cQryMen+=" AND RGG_CODIRC=RA_CODIRCT "
		cQryMen+=" AND RGG_CODIGO=RA_CODCAT "
		cQryMen+=" AND RGG.D_E_L_E_T_='' "
		cQryMen+=" WHERE SRA.D_E_L_E_T_='' "
		cQryMen+=" AND RA_FILIAL='"+cParFilial+"' "		
		cQryMen+=" AND(RA_ADMISSA <= '"+cParAnoBas+"1231' AND RA_DEMISSA='') "
		cQryMen+=" OR  (RA_DEMISSA >= '"+cParAnoBas+"0101' AND RA_DEMISSA <= '"+cParAnoBas+"1231') "
		cQryMen+=" AND RA_TIPOCO<>'' "
		cQryMen+=" WHERE SRA.D_E_L_E_T_='' "  
		cQryMen+=" ORDER BY RA_SALARIO "		
		cQryMen:= ChangeQuery(cQryMen)
		If Select("LEQMEN")>0
			DbSelectArea("LEQMEN")
			LEQSAL->(DbCloseArea())
		Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryLeq),"LEQMEN",.F.,.T.)
		DbSelectArea("LEQMEN")
		LEQMEN->(dbGoTop()) 
		If LEQMEN->(!Eof())
		   nQtdMen:=1
		   Do While LEQMEN->(!Eof()) 
		    	If nQtdMen>nQtdFun
		            nSalMen:=IIF(LEQMEN->RA_SALARIO=0,1,LEQMEN->RA_SALARIO)
		   			Exit
		        Endif
				LEQMEN->(DbSkip())   		     
		   End
		Endif
		//Item 2.10 - Leque Salarial Interpretativo		
		nSalInt:=nSalMai/nSalMen         
	Endif
	Aadd(aCustPes,{"C","2.9"," "," "," "," "," ",0,0,nSalLiq,0})//Salario Direto
	Aadd(aCustPes,{"C","2.10"," "," "," "," "," ",0,0,nSalInt,0})//Salario Base
	aAdd( aLogProc, {"2"," ","013"} )	
	aAdd( aLogProc, {"2",STR0155,"014"} )//"Leque Salarial"
	aAdd( aLogProc, {"2",STR0156+Transform(nSalLiq,"@E 999,999,999.99"),"015"} )//"   2.9  - Direto                              "
	aAdd( aLogProc, {"2",STR0157+Transform(nSalInt,"@E 999,999,999.99"),"016"} )//"   2.10 - Interpretativo                      "


Endif	

If Len(aCustPes)>0
	MsgRun(STR0158,STR0047, {||GravaRGN(aCustPes)})
Endif	

Return       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ HigSegBS ³ Autor ³ Marcos Kato		      ³ Data ³   25.07.08    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Higiene e Seguranca 											     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Portugal                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³           ³											 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function HigSegBS()
//3.1 *************ACIDENTES DE TRABALHO
//Item 3.1.1 - Numero total de acidentes 
//Item 3.1.2 - Numero total de acidentes com baixa 
//Item 3.1.3 - Numero de dias perdidos com baixa
//Item 3.1.4 - Numero de casos de incapacidade permanente declarados no ano 
	//Item 3.1.4.1 - Numero de casos de incapacidade permanente absoluta
	//Item 3.1.4.2 - Numero de casos de incapacidade parcial
//3.2 *************DOENCAS PROFISSIONAIS

//3.3 *************ATIVIDADE DA MEDICINA DO TRABALHO
//Item 3.3.1 - Exames de Admissão
//Item 3.3.2 - Exames Periódicos
//Item 3.3.3 - Exames ocasionais e complementares
//Item 3.3.2 - N° de Visitas efetuadas aos postos de trabalho
//Item 3.3.3 - Despesa com a Medicina do Trabalho 
//3.4 *************COMISSOES DE HIGIENE E SEGURANCA 
//Item 3.4.1 - Reuniões anuais de Higiene e segurança
//Item 3.4.2 - Visitas aos locais de trabalho
//3.5 *************PESSOAS RECLASSIFICADAS OU RECOLOCADAS EM RESULTADO DE ACIDENTES DE TRABALHO
//Item 3.5.1 - N° de Pessoas
//3.6 *************NUMERO DE PARTICIPANTES
//Item 3.6.1 - N° de ações desenvolvidas
//Item 3.6.2 - N° de pessoas abrangidas pela acoes
//3.7 *************CUSTOS COM A PREVENCAO DE ACIDENTES E DOENCAS PROFISSIONAIS
//Item 3.7.1 - Encargos da estrutura da medicina de trabalho e segurança no trabalho
//Item 3.7.2 - Custos com equipamento de proteção
//Item 3.7.3 - Custos com formação e prevenção em risco
//Item 3.7.4 - Outros custos


Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ForProBS ³ Autor ³ Marcos Kato		      ³ Data ³   25.07.08    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Formacao Profissional										     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Portugal                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³           ³											 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ForProBS()
//4.1 *************NUMERO DE ACOES
//Item 4.1.1 - N° de Ações Internas
//Item 4.1.2 - N° de Ações Externas
//4.2 *************NUMERO DE PARTICIPANTES
//Item 4.2.1 - Numero de Participantes em ações internas
//Item 4.2.2 - Numero de Participantes em ações externas
//4.3 *************DURACAO DAS ACOES
//Item 4.3.1 - N° de Horas em ações internas
//Item 4.3.2 - N° de Horas em ações externas
//4.4 *************CUSTOS TOTAIS DE FORMACAO
//Item 4.4.1 - Custos em ações internas
//Item 4.4.2 - Custos em ações externas

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ProSCoBS ³ Autor ³ Marcos Kato		      ³ Data ³   25.07.08    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Protecao Social Complementar									     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Portugal                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³           ³											 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProSCoBS() 
Local cQryEnc:=""                                           
Local aEncSocP:={}
Local nvalA:=0,	nValB:=0, nValC:=0,	nValD:=0, nValE:=0,	nValF:=0
Local nQtdA:=0,	nQtdB:=0, nQtdC:=0,	nQtdD:=0, nQtdE:=0,	nQtdF:=0
Local nPesA:=0,	nPesB:=0, nPesC:=0,	nPesD:=0, nPesE:=0,	nPesF:=0

cQryEnc:="SELECT DISTINCT RD_MAT, "
cQryEnc+="CASE WHEN RV_ESOCBS LIKE '%A%' THEN  SUM(RD_VALOR) ELSE 0 END A, "
cQryEnc+="CASE WHEN RV_ESOCBS LIKE '%B%' THEN  SUM(RD_VALOR) ELSE 0 END B, "
cQryEnc+="CASE WHEN RV_ESOCBS LIKE '%C%' THEN  SUM(RD_VALOR) ELSE 0 END C, "
cQryEnc+="CASE WHEN RV_ESOCBS LIKE '%D%' THEN  SUM(RD_VALOR) ELSE 0 END D, "
cQryEnc+="CASE WHEN RV_ESOCBS LIKE '%E%' THEN  SUM(RD_VALOR) ELSE 0 END E, "
cQryEnc+="CASE WHEN RV_ESOCBS LIKE '%F%' THEN  SUM(RD_VALOR) ELSE 0 END F "
cQryEnc+="FROM "+RetSqlName("SRD")+" SRD "
cQryEnc+="INNER JOIN "+RetSqlName("SRV")+" SRV ON "
cQryEnc+="RV_FILIAL=RD_FILIAL "
cQryEnc+="AND RV_COD=RD_PD  "
cQryEnc+="AND RV_ESOCBS<>'' "
cQryEnc+="AND SRV.D_E_L_E_T_='' "
cQryEnc+="WHERE SRD.D_E_L_E_T_='' "                      
cQryEnc+="AND RD_FILIAL='"+cParFilial+"' "
cQryEnc+="AND SUBSTRING(RD_DATARQ,1,4)='"+cParAnoBas+"' "
cQryEnc+="GROUP BY RD_MAT,RV_ESOCBS "

If Select("EPRSOC")>0
	DbSelectArea("EPRSOC")
	EPRSOC->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryEnc),"EPRSOC",.F.,.T.)
DbSelectArea("EPRSOC")
EPRSOC->(dbGoTop()) 
If EPRSOC->(!Eof())
	Do While EPRSOC->(!Eof())
		cMatr:=EPRSOC->RD_MAT
		nPesA:=1		
		nPesB:=1			
		nPesC:=1		
		nPesD:=1			
		nPesE:=1		
		nPesF:=1		
 		Do While EPRSOC->(!Eof()) .And. cMatr==EPRSOC->RD_MAT
 			If EPRSOC->A>0
 				nValA+=EPRSOC->A
 				nQtdA+=nPesA
 				nPesA:=0
 			Endif
 			If EPRSOC->B>0
 				nValB+=EPRSOC->B			
 				nQtdB+=nPesB 				
 				nPesB:=0 				
 			Endif	
			If EPRSOC->C>0
 				nValC+=EPRSOC->C			
 				nQtdC+=nPesC 				
 				nPesC:=0 				
			Endif
			If EPRSOC->D>0
 				nValD+=EPRSOC->D			
 				nQtdD+=nPesD 				
 				nPesD:=0 				
			Endif
			If EPRSOC->E>0
 				nValE+=EPRSOC->E			
 				nQtdE+=nPesE 				
 				nPesE:=0 				
			Endif
			If EPRSOC->F>0 			
 				nValF+=EPRSOC->F            
 				nQtdF+=nPesF 				
 				nPesF:=0 				
			Endif
		EPRSOC->(DbSkip())
		End
	End
Endif
//5.1 *************ENCARGOS (PRESTACOES) DE PROTECAO SOCIAL DIRETAMENTE SUPORTADOS PELA EMPRESA
//Item 5.1.1 - Complementos de Subsidio por doença e doença profissional (Prestações)
//Item 5.1.2 - Complementos de pensões de velhice, de invalidez e de sobrevivência (Prestações)
//Item 5.1.3 - Complementos de outras prestações de segurança Social (Prestações)         
Aadd(aEncSocP,{"S","5.1.1"," "," "," "," "," ",nPesA,0,nValA,0})//Salario Direto
Aadd(aEncSocP,{"S","5.1.2"," "," "," "," "," ",nQtdB,0,nValB,0})//Salario Base
Aadd(aEncSocP,{"S","5.1.3"," "," "," "," "," ",nQtdC,0,nValC,0})//Salario Base
aAdd( aLogProc, {"5"," ","001"} )	
aAdd( aLogProc, {"5",STR0159                       ,"002"} )//"Encargos (Prestacoes) de Protecao Social diretamente suportado pela Empresa"
aAdd( aLogProc, {"5","   5.1.1  - "+STR0161                ,"003"} )
aAdd( aLogProc, {"5","   "+STR0164+" - "+Transform(nValA,"@E 999,999,999.99")+"        "+STR0165+Transform(nQtdA,"@E 999999"),"004"} )//Valor#Qtd.Pessoa
aAdd( aLogProc, {"5","   5.1.2  - "+STR0162                ,"005"} )
aAdd( aLogProc, {"5","   "+STR0164+" - "+Transform(nValB,"@E 999,999,999.99")+"        "+STR0165+Transform(nQtdB,"@E 999999"),"006"} )
aAdd( aLogProc, {"5","   5.1.3  - "+STR0163                ,"007"} )
aAdd( aLogProc, {"5","   "+STR0164+" - "+Transform(nValC,"@E 999,999,999.99")+"        "+STR0165+Transform(nQtdC,"@E 999999"),"008"} )
//5.2 *************ENCARGOS (PREMIOS) POR PROTECAO SOCIAL NAO ADMINISTRADO PELA EMPRESA
//Item 5.2.1 - Complementos de Subsidio por doença e doença profissional (Premios)
//Item 5.2.2 - Complementos de pensões de velhice, de invalidez e de sobrevivência(Premios)
//Item 5.2.3 - Complementos de outras prestações de segurança Social (Premios)
Aadd(aEncSocP,{"S","5.2.1"," "," "," "," "," ",nQtdD,0,nValD,0})//Salario Direto
Aadd(aEncSocP,{"S","5.2.2"," "," "," "," "," ",nQtdE,0,nValE,0})//Salario Base
Aadd(aEncSocP,{"S","5.2.3"," "," "," "," "," ",nQtdF,0,nValF,0})//Salario Base
aAdd( aLogProc, {"5"," ","009"} )	
aAdd( aLogProc, {"5",STR0160                       ,"010"} )//"Encargos (Prestacoes) de Protecao Social diretamente suportado pela Empresa"
aAdd( aLogProc, {"5","   5.2.1  - "+STR0161                ,"011"} )//Complementos de Subsidio por doença e doença profissional           : "
aAdd( aLogProc, {"5","   "+STR0164+" - "+Transform(nValD,"@E 999,999,999.99")+"        "+STR0165+Transform(nQtdD,"@E 999999"),"012"} )
aAdd( aLogProc, {"5","   5.2.2  - "+STR0162                ,"013"} )//Complementos de pensões de velhice, de invalidez e de sobrevivência : "
aAdd( aLogProc, {"5","   "+STR0164+" - "+Transform(nValE,"@E 999,999,999.99")+"        "+STR0165+Transform(nQtdE,"@E 999999"),"014"} )
aAdd( aLogProc, {"5","   5.2.3  - "+STR0163                ,"015"} )//Complementos de outras prestações de segurança Social               : "
aAdd( aLogProc, {"5","   "+STR0164+" - "+Transform(nValF,"@E 999,999,999.99")+"        "+STR0165+Transform(nQtdF,"@E 999999"),"016"} )

//5.3 *************PRESTACOES DE ACAO SOCIAL
//Item 5.3.1 - Apoio a Infância
//Item 5.3.2 - Apoio a Idosos
//Item 5.3.3 - Apoio a tempos livres
//Item 5.3.4 - Outros Apoios 
//5.4 *************OUTRAS MODALIDADES DE APOIO SOCIAL
//Item 5.4.1 - Grupo desportivo/casa de pessoal(designacao equivalente)
//Item 5.4.2 - Alimentação
//Item 5.4.3 - Apoio a estudos
//Item 5.4.4 - Saúde
//Item 5.4.5 - Habitacao
//Item 5.4.6 - Transportes
//Item 5.4.7 - Seguros especiais
//Item 5.4.8 - Adiantamentos e empréstimos
//Item 5.4.9 - Outros apoios

If Len(aEncSocP)>0
	MsgRun(STR0166,STR0047, {||GravaRGN(aEncSocP)})//"Processando Encargo Social Complementar"
Endif	

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ HistCont ³ Autor ³ Marcos Kato		      ³ Data ³   25.07.08    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Historico de Contrato										     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Portugal                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³           ³											 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function HistCont(cMatr,cTpCont,cTipo)
//=========================
//Conteudo do cTipo
//QP-Quadro Permanente
//AA-Ano Anterior
//=========================
Local cAnoAnt	:=Alltrim(Str(Val(cParAnoBas)-1))
Local nAltCont	:=0//Contador da alteracao de contrato
Local nRet		:=0
//Historico de Contrato
DbSelectArea("RGE")
RGE->(DbSetOrder(2))
RGE->(DbGoTop())
If DbSeek(cParFilial+cMatr)
	Do While RGE->(!Eof()) .And. RGE->RGE_MAT==cMatr
		DbSelectArea("RCC")
		RCC->(DbSetOrder(1))
		RCC->(DbGoTop())
		If DbSeek(cParFilial+"S011")
			Do While RCC->(!Eof())	
				If RGE->RGE_TIPOCO==Substr(RCC_CONTEU,1,2)
			        cContrBS:=Substr(RCC_CONTEU,78,1)
			    	Exit
				Endif
				RCC->(DbSkip())
			End
		Endif
		If cContrBS=="1"
			//Quadro Permanente
			//Somente sera considerado uma alteracao de contrato quando tiver mais de 1 registro no historico
			//e o tipo de contrato seja permanente e esta no periodo informado.
			If nAltCont>1 .And. cTipo=="QP" .And. ;
				RGE->RGE_DATAIN >=CTOD("01/01"+SUBSTR(cParAnoBas,3,2)) .And. ;
				RGE->RGE_DATAIN <=CTOD("31/12"+SUBSTR(cParAnoBas,3,2))
				nRet:=1
			Endif
		ElseIf cContrBS$"2*3"
			//Verifica somente contrato termo certo e incerto do ano anterior e que mantenha o mesmo vinculo
			If RGE->RGE_TIPOCO==STRZERO(cTpCont,2) .And. cTipo=="AA" .And. ;
				RGE->RGE_DATAIN >=CTOD("01/01"+SUBSTR(cAnoAnt,3,2)) .And. ;
				RGE->RGE_DATAIN <=CTOD("31/12"+SUBSTR(cAnoAnt,3,2))
				nRet:=1
			Endif
		Endif
		nAltCont++
		RGE->(DbSkip())
	End
Endif
Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PosTrab ³ Autor ³ Marcos Kato		      ³ Data ³   25.07.08    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Posicao de Trabalho												     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Portugal                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³           ³											 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PostTrab()

Local cQryPos	:=""
Local aPostTrab	:={}
Local nCnt:=0,nPTrab

cQryPos:="SELECT RCL_POSTO,Q3_DESCSUM,(SUM(RCL_NPOSTO)-SUM(RCL_OPOSTO)) QTD "
cQryPos+="FROM "+RETSQLNAME("RCL")+" RCL "
cQryPos+="INNER JOIN "+RETSQLNAME("SQ3")+" SQ3 ON "
cQryPos+="( "
cQryPos+="RCL_POSTO=Q3_CARGO "
cQryPos+="AND SQ3.D_E_L_E_T_='' "
cQryPos+=") "
cQryPos+="WHERE RCL.D_E_L_E_T_='' "
cQryPos+="AND RCL_FILIAL='"+cParFilial+"' "
cQryPos+="AND SUBSTRING(RCL_DTINI,1,4)='"+cParAnoBas+"' "
cQryPos+="AND RCL_DTFIM='' "
cQryPos+="GROUP BY RCL_POSTO,Q3_DESCSUM "


cQryPos := ChangeQuery(cQryPos)

If Select("TRBPOS")>0
	DbSelectArea("TRBPOS")
	TRBPOS->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryPos),"TRBPOS",.F.,.T.)

DbSelectArea("TRBPOS")
TRBPOS->(dbGoTop())

If TRBPOS->(!Eof())
	Do While TRBPOS->(!Eof())
		If TRBPOS->QTD>0      
			nCnt++
			Aadd(aPostTrab,{"F","1.14",StrZero(nCnt,4),TRBPOS->Q3_DESSCSUM," "," "," ",TRBPOS->QTD,0,0,0})
						
		Endif
		TRBPOS->(DbSkip())
	End
Endif
If Len(aPostTrab)==0
	Aadd(aPostTrab,{"F","1.14","0001"," "," "," "," ",0,0,0,0})
Endif
//==================================================================
//MONTAGEM DO LOG DO BALANCO SOCIAL - EMPREGOS                    
//==================================================================
aAdd( aLogProc, {"1",Replicate("-",130),"189"})
aAdd( aLogProc, {"1",STR0167,"190"} )//"1.14 - Postos de Trabalho nao ocupados por dificuldade de recrutamento"        
aAdd( aLogProc, {"1",STR0168+"                                        "+STR0169,"191"} )        
For nPTrab:=1 To Len(aPostTrab)  
	If nPTrab<=12
		aAdd( aLogProc, {"1",aPostTrab[nPTrab][6]+Space(50-Len(aPostTrab[nPTrab][6]))+Transform(aPostTrab[nPTrab][10],"@E 999999"),Alltrim(Str(Val("191")+nPTrab))} )
	Endif	
Next
aAdd( aLogProc, {"1"," ","205"} )

MsgRun(STR0170,STR0047, {||GravaRGN(aPostTrab)})//"Processando Dificuldade Recrutamento de Posto"

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MotSaida ³ Autor ³ Marcos Kato		      ³ Data ³   25.07.08    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Motivo de Saida												     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Portugal                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³           ³											 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MotSaida()
Local aMotSai:={}
Local cQrySai:=""                           
Local nCont1:=0,nCont2:=0
Local aEmpr4 := ARRAY(16,8)//Motivo de saida
cQrySai:="SELECT RGG_NIVEL,RG_TIPORES,COUNT(1) QTD, "
cQrySai+="RA_DEFIFIS,RA_GRINRAI,RA_CPAISOR,SUBSTRING(RCC_CONTEU,78,1) TIPOCOBS "
cQrySai+="FROM "+RETSQLNAME("SRA")+" SRA "
cQrySai+="INNER JOIN "+RETSQLNAME("SRG")+" SRG ON "
cQrySai+="RG_FILIAL=RA_FILIAL "
cQrySai+="AND RG_MAT=RA_MAT "
cQrySai+="AND SUBSTRING(RG_DATADEM,1,4)='"+ALLTRIM(cParAnoBas)+"' "
cQrySai+="AND SRG.D_E_L_E_T_='' "                  
cQrySai+="LEFT JOIN "+RETSQLNAME("RGG")+" RGG ON  "
cQrySai+="RGG_FILIAL=RA_FILIAL "
cQrySai+="AND RGG_CODIRC=RA_CODIRCT "
cQrySai+="AND RGG_CODIGO = RA_CODCAT "
cQrySai+="AND RGG.D_E_L_E_T_='' " 
cQrySai+="LEFT JOIN "+RetSqlName("RCC")+" RCC ON "
cQrySai+="RCC_CODIGO='S011' "
cQrySai+="AND SUBSTRING(RCC_CONTEU,1,2)=RA_TIPOCO "
cQrySai+="AND RCC.D_E_L_E_T_='' "     
cQrySai+="WHERE SRA.D_E_L_E_T_='' "
cQrySai+="AND RA_FILIAL='"+cParFilial+"' "
cQrySai+="AND (RA_ADMISSA <= '"+cParAnoBas+"1231' AND RA_DEMISSA = '' ) "
cQrySai+="OR  (RA_DEMISSA >= '"+cParAnoBas+"0101' AND RA_DEMISSA <= '"+cParAnoBas+"1231') "
cQrySai+="AND RA_TIPOCO<>'' " 
cQrySai+="GROUP BY RGG_NIVEL,RG_TIPORES,RA_DEFIFIS,RA_GRINRAI,RA_CPAISOR, RCC_CONTEU "

cQrySai := ChangeQuery(cQrySai)

If Select("MOTSAI")>0
	DbSelectArea("MOTSAI")
	MOTSAI->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySai),"MOTSAI",.F.,.T.)

DbSelectArea("MOTSAI")
MOTSAI->(DbGoTop())
If MOTSAI->(!Eof())       

	For nCont1:=1 To 16
		For nCont2:=1 To 8
			aEmpr4[nCont1][nCont2]	:=0
		Next
	Next
    
	aAdd( aLogProc, {"1",STR0171,"165"} )//"Motivo de Saida"
	Do While MOTSAI->(!Eof())
		If MOTSAI->RGG_NIVEL=="1"
			nCateg:=1 //Dirigente
		ElseIf MOTSAI->RGG_NIVEL=="2"
			nCateg:=2//Quadro Superior
		ElseIf MOTSAI->RGG_NIVEL=="3"
			nCateg:=3//Quadro Medio
		ElseIf MOTSAI->RGG_NIVEL=="4"
			nCateg:=4//Quadro Intermediario
		ElseIf MOTSAI->RGG_NIVEL=="5"
			nCateg:=5 //Profissionais altamente qualificados e qualificados
		ElseIf MOTSAI->RGG_NIVEL=="6"
			nCateg:=6 //Profissionais semiqualificados
		ElseIf MOTSAI->RGG_NIVEL=="7"
			nCateg:=7 //Profissionais nao qualificados
		ElseIf MOTSAI->RGG_NIVEL=="8"
			nCateg:=8 //Praticantes\Aprendizes
		Else
			nCateg:=0
		Endif
        If nCateg<>0
			If MOTSAI->TIPOCOBS=="1"//Contrato Permanente
				If MOTSAI->RG_TIPORES=="10"
					aEmpr4[1][nCateg]:=MOTSAI->QTD 
				ElseIf RG_TIPORES=="12"
					aEmpr4[2][nCateg]:=MOTSAI->QTD
				ElseIf RG_TIPORES=="09"
					aEmpr4[3][nCateg]:=MOTSAI->QTD
				ElseIf RG_TIPORES=="07"
					aEmpr4[4][nCateg]:=MOTSAI->QTD
				ElseIf RG_TIPORES=="08"
					aEmpr4[5][nCateg]:=MOTSAI->QTD
				ElseIf RG_TIPORES=="13"
					aEmpr4[6][nCateg]:=MOTSAI->QTD
				ElseIf RG_TIPORES=="05"
					aEmpr4[7][nCateg]:=MOTSAI->QTD
				ElseIf RG_TIPORES=="14"
					aEmpr4[8][nCateg]:=MOTSAI->QTD
				ElseIf RG_TIPORES=="15"
					aEmpr4[9][nCateg]:=MOTSAI->QTD
				ElseIf RG_TIPORES=="16"
					aEmpr4[10][nCateg]:=MOTSAI->QTD
				Else
					aEmpr4[15][nCateg]+=MOTSAI->QTD
				Endif
			ElseIf MOTSAI->TIPOCOBS$"2|3"//Contrato a Termo
				If RG_TIPORES=="01"
					aEmpr4[11][nCateg]:=MOTSAI->QTD
				ElseIf RG_TIPORES=="02"
					aEmpr4[12][nCateg]:=MOTSAI->QTD
				ElseIf RG_TIPORES=="17"
					aEmpr4[13][nCateg]:=MOTSAI->QTD
				ElseIf RG_TIPORES=="18"
					aEmpr4[14][nCateg]:=MOTSAI->QTD
				Else
					aEmpr4[15][nCateg]+=MOTSAI->QTD
				Endif
			Endif
		Endif	
		SRG->(DbSkip())
	End
Endif
Aadd(aMotSai,{"F","1.11.01","0702"," ","","","",aEmpr4[1][2],0,0,0})
Aadd(aMotSai,{"F","1.11.01","0703"," ","","","",aEmpr4[1][3],0,0,0})
Aadd(aMotSai,{"F","1.11.01","0704"," ","","","",aEmpr4[1][4],0,0,0})
Aadd(aMotSai,{"F","1.11.01","0705"," ","","","",aEmpr4[1][5],0,0,0})
Aadd(aMotSai,{"F","1.11.01","0706"," ","","","",aEmpr4[1][6],0,0,0})
Aadd(aMotSai,{"F","1.11.01","0707"," ","","","",aEmpr4[1][7],0,0,0})
Aadd(aMotSai,{"F","1.11.01","0708"," ","","","",aEmpr4[1][8],0,0,0})
//Mutuo acordo
Aadd(aMotSai,{"F","1.11.02","0702"," ","","","",aEmpr4[2][2],0,0,0})
Aadd(aMotSai,{"F","1.11.02","0703"," ","","","",aEmpr4[2][3],0,0,0})
Aadd(aMotSai,{"F","1.11.02","0704"," ","","","",aEmpr4[2][4],0,0,0})
Aadd(aMotSai,{"F","1.11.02","0705"," ","","","",aEmpr4[2][5],0,0,0})
Aadd(aMotSai,{"F","1.11.02","0706"," ","","","",aEmpr4[2][6],0,0,0})
Aadd(aMotSai,{"F","1.11.02","0707"," ","","","",aEmpr4[2][7],0,0,0})
Aadd(aMotSai,{"F","1.11.02","0708"," ","","","",aEmpr4[2][8],0,0,0})
//iniciativa da Empresa
Aadd(aMotSai,{"F","1.11.03","0702"," ","","","",aEmpr4[3][2],0,0,0})
Aadd(aMotSai,{"F","1.11.03","0703"," ","","","",aEmpr4[3][3],0,0,0})
Aadd(aMotSai,{"F","1.11.03","0704"," ","","","",aEmpr4[3][4],0,0,0})
Aadd(aMotSai,{"F","1.11.03","0705"," ","","","",aEmpr4[3][5],0,0,0})
Aadd(aMotSai,{"F","1.11.03","0706"," ","","","",aEmpr4[3][6],0,0,0})
Aadd(aMotSai,{"F","1.11.03","0707"," ","","","",aEmpr4[3][7],0,0,0})
Aadd(aMotSai,{"F","1.11.03","0708"," ","","","",aEmpr4[3][8],0,0,0})
//Despedimento (Coletivo)
Aadd(aMotSai,{"F","1.11.04","0702"," ","","","",aEmpr4[4][2],0,0,0})
Aadd(aMotSai,{"F","1.11.04","0703"," ","","","",aEmpr4[4][3],0,0,0})
Aadd(aMotSai,{"F","1.11.04","0704"," ","","","",aEmpr4[4][4],0,0,0})
Aadd(aMotSai,{"F","1.11.04","0705"," ","","","",aEmpr4[4][5],0,0,0})
Aadd(aMotSai,{"F","1.11.04","0706"," ","","","",aEmpr4[4][6],0,0,0})
Aadd(aMotSai,{"F","1.11.04","0707"," ","","","",aEmpr4[4][7],0,0,0})
Aadd(aMotSai,{"F","1.11.04","0708"," ","","","",aEmpr4[4][8],0,0,0})
//Despedimento Artigo 26
Aadd(aMotSai,{"F","1.11.05","0702"," ","","","",aEmpr4[5][2],0,0,0})
Aadd(aMotSai,{"F","1.11.05","0703"," ","","","",aEmpr4[5][3],0,0,0})
Aadd(aMotSai,{"F","1.11.05","0704"," ","","","",aEmpr4[5][4],0,0,0})
Aadd(aMotSai,{"F","1.11.05","0705"," ","","","",aEmpr4[5][5],0,0,0})
Aadd(aMotSai,{"F","1.11.05","0706"," ","","","",aEmpr4[5][6],0,0,0})
Aadd(aMotSai,{"F","1.11.05","0707"," ","","","",aEmpr4[5][7],0,0,0})
Aadd(aMotSai,{"F","1.11.05","0708"," ","","","",aEmpr4[5][8],0,0,0})
//Reforma por invalidez
Aadd(aMotSai,{"F","1.11.06","0702"," ","","","",aEmpr4[6][2],0,0,0})
Aadd(aMotSai,{"F","1.11.06","0703"," ","","","",aEmpr4[6][3],0,0,0})
Aadd(aMotSai,{"F","1.11.06","0704"," ","","","",aEmpr4[6][4],0,0,0})
Aadd(aMotSai,{"F","1.11.06","0705"," ","","","",aEmpr4[6][5],0,0,0})
Aadd(aMotSai,{"F","1.11.06","0706"," ","","","",aEmpr4[6][6],0,0,0})
Aadd(aMotSai,{"F","1.11.06","0707"," ","","","",aEmpr4[6][7],0,0,0})
Aadd(aMotSai,{"F","1.11.06","0708"," ","","","",aEmpr4[6][8],0,0,0})
//Reforma por velhice                                   
Aadd(aMotSai,{"F","1.11.07","0702"," ","","","",aEmpr4[7][2],0,0,0})
Aadd(aMotSai,{"F","1.11.07","0703"," ","","","",aEmpr4[7][3],0,0,0})
Aadd(aMotSai,{"F","1.11.07","0704"," ","","","",aEmpr4[7][4],0,0,0})
Aadd(aMotSai,{"F","1.11.07","0705"," ","","","",aEmpr4[7][5],0,0,0})
Aadd(aMotSai,{"F","1.11.07","0706"," ","","","",aEmpr4[7][6],0,0,0})
Aadd(aMotSai,{"F","1.11.07","0707"," ","","","",aEmpr4[7][7],0,0,0})
Aadd(aMotSai,{"F","1.11.07","0708"," ","","","",aEmpr4[7][8],0,0,0})
//reforma Antecipada
Aadd(aMotSai,{"F","1.11.08","0702"," ","","","",aEmpr4[8][2],0,0,0})
Aadd(aMotSai,{"F","1.11.08","0703"," ","","","",aEmpr4[8][3],0,0,0})
Aadd(aMotSai,{"F","1.11.08","0704"," ","","","",aEmpr4[8][4],0,0,0})
Aadd(aMotSai,{"F","1.11.08","0705"," ","","","",aEmpr4[8][5],0,0,0})
Aadd(aMotSai,{"F","1.11.08","0706"," ","","","",aEmpr4[8][6],0,0,0})
Aadd(aMotSai,{"F","1.11.08","0707"," ","","","",aEmpr4[8][7],0,0,0})
Aadd(aMotSai,{"F","1.11.08","0708"," ","","","",aEmpr4[8][8],0,0,0})
//Pre-reforma
Aadd(aMotSai,{"F","1.11.09","0702"," ","","","",aEmpr4[9][2],0,0,0})
Aadd(aMotSai,{"F","1.11.09","0703"," ","","","",aEmpr4[9][3],0,0,0})
Aadd(aMotSai,{"F","1.11.09","0704"," ","","","",aEmpr4[9][4],0,0,0})
Aadd(aMotSai,{"F","1.11.09","0705"," ","","","",aEmpr4[9][5],0,0,0})
Aadd(aMotSai,{"F","1.11.09","0706"," ","","","",aEmpr4[9][6],0,0,0})
Aadd(aMotSai,{"F","1.11.09","0707"," ","","","",aEmpr4[9][7],0,0,0})
Aadd(aMotSai,{"F","1.11.09","0708"," ","","","",aEmpr4[9][8],0,0,0})
//Falecimento
Aadd(aMotSai,{"F","1.11.10","0702"," ","","","",aEmpr4[10][2],0,0,0})
Aadd(aMotSai,{"F","1.11.10","0703"," ","","","",aEmpr4[10][3],0,0,0})
Aadd(aMotSai,{"F","1.11.10","0704"," ","","","",aEmpr4[10][4],0,0,0})
Aadd(aMotSai,{"F","1.11.10","0705"," ","","","",aEmpr4[10][5],0,0,0})
Aadd(aMotSai,{"F","1.11.10","0706"," ","","","",aEmpr4[10][6],0,0,0})
Aadd(aMotSai,{"F","1.11.10","0707"," ","","","",aEmpr4[10][7],0,0,0})
Aadd(aMotSai,{"F","1.11.10","0708"," ","","","",aEmpr4[10][8],0,0,0})
//Cessacao do Contrato a Termo Certo
Aadd(aMotSai,{"F","1.12.01","0702"," ","","","",aEmpr4[11][2],0,0,0})
Aadd(aMotSai,{"F","1.12.01","0703"," ","","","",aEmpr4[11][3],0,0,0})
Aadd(aMotSai,{"F","1.12.01","0704"," ","","","",aEmpr4[11][4],0,0,0})
Aadd(aMotSai,{"F","1.12.01","0705"," ","","","",aEmpr4[11][5],0,0,0})
Aadd(aMotSai,{"F","1.12.01","0706"," ","","","",aEmpr4[11][6],0,0,0})
Aadd(aMotSai,{"F","1.12.01","0707"," ","","","",aEmpr4[11][7],0,0,0})
Aadd(aMotSai,{"F","1.12.01","0708"," ","","","",aEmpr4[11][8],0,0,0})
//Cessacao do Contrato a Termo InCerto
Aadd(aMotSai,{"F","1.12.02","0702"," ","","","",aEmpr4[12][2],0,0,0})
Aadd(aMotSai,{"F","1.12.02","0703"," ","","","",aEmpr4[12][3],0,0,0})
Aadd(aMotSai,{"F","1.12.02","0704"," ","","","",aEmpr4[12][4],0,0,0})
Aadd(aMotSai,{"F","1.12.02","0705"," ","","","",aEmpr4[12][5],0,0,0})
Aadd(aMotSai,{"F","1.12.02","0706"," ","","","",aEmpr4[12][6],0,0,0})
Aadd(aMotSai,{"F","1.12.02","0707"," ","","","",aEmpr4[12][7],0,0,0})
Aadd(aMotSai,{"F","1.12.02","0708"," ","","","",aEmpr4[12][8],0,0,0})
//Antecipacao da cessacao a Termo Certo
Aadd(aMotSai,{"F","1.12.03","0702"," ","","","",aEmpr4[13][2],0,0,0})
Aadd(aMotSai,{"F","1.12.03","0703"," ","","","",aEmpr4[13][3],0,0,0})
Aadd(aMotSai,{"F","1.12.03","0704"," ","","","",aEmpr4[13][4],0,0,0})
Aadd(aMotSai,{"F","1.12.03","0705"," ","","","",aEmpr4[13][5],0,0,0})
Aadd(aMotSai,{"F","1.12.03","0706"," ","","","",aEmpr4[13][6],0,0,0})
Aadd(aMotSai,{"F","1.12.03","0707"," ","","","",aEmpr4[13][7],0,0,0})
Aadd(aMotSai,{"F","1.12.03","0708"," ","","","",aEmpr4[13][8],0,0,0})
//Antecipacao da cessacao a Termo InCerto
Aadd(aMotSai,{"F","1.12.04","0702"," ","","","",aEmpr4[14][2],0,0,0})
Aadd(aMotSai,{"F","1.12.04","0703"," ","","","",aEmpr4[14][3],0,0,0})
Aadd(aMotSai,{"F","1.12.04","0704"," ","","","",aEmpr4[14][4],0,0,0})
Aadd(aMotSai,{"F","1.12.04","0705"," ","","","",aEmpr4[14][5],0,0,0})
Aadd(aMotSai,{"F","1.12.04","0706"," ","","","",aEmpr4[14][6],0,0,0})
Aadd(aMotSai,{"F","1.12.04","0707"," ","","","",aEmpr4[14][7],0,0,0})
Aadd(aMotSai,{"F","1.12.04","0708"," ","","","",aEmpr4[14][8],0,0,0})
//Outros motivos de saida do pessoal
Aadd(aMotSai,{"F","1.13","0702"," ","","","",aEmpr4[15][2],0,0,0})
Aadd(aMotSai,{"F","1.13","0703"," ","","","",aEmpr4[15][3],0,0,0})
Aadd(aMotSai,{"F","1.13","0704"," ","","","",aEmpr4[15][4],0,0,0})
Aadd(aMotSai,{"F","1.13","0705"," ","","","",aEmpr4[15][5],0,0,0})
Aadd(aMotSai,{"F","1.13","0706"," ","","","",aEmpr4[15][6],0,0,0})
Aadd(aMotSai,{"F","1.13","0707"," ","","","",aEmpr4[15][7],0,0,0})
Aadd(aMotSai,{"F","1.13","0708"," ","","","",aEmpr4[15][8],0,0,0})

MsgRun(STR0172,STR0047, {||GravaRGN(aMotSai)})//"Processando Motivo de Saida"

//==================================================================
//MONTAGEM DO LOG DO BALANCO SOCIAL - EMPREGOS                    
//==================================================================
aAdd( aLogProc, {"1",Replicate("-",130),"166"})
aAdd( aLogProc, {"1",STR0173,"167"} )        
aAdd( aLogProc, {"1",STR0193,"168"} )//"                                      Quadro Sup.   Quadro Med.    Quadro Int. Prof.Alt.Qual.   Prof.Semi. Prof.nao Qual. Prat\Aprend "
aAdd( aLogProc, {"1","1.11.1 - "+STR0174+" -      "+Transform(aEmpr4[1][2],"@E 999999")+'        '+Transform(aEmpr4[1][3],"@E 999999")+'        '+Transform(aEmpr4[1][4],"@E 999999");
+'        '+Transform(aEmpr4[1][5],"@E 999999")+'        '+Transform(aEmpr4[1][6],"@E 999999")+'        '+Transform(aEmpr4[1][7],"@E 999999")+'        '+Transform(aEmpr4[1][8],"@E 999999"),"169"} )
aAdd( aLogProc, {"1","1.11.2 - "+STR0175+"              -      "+Transform(aEmpr4[2][2],"@E 999999")+'        '+Transform(aEmpr4[2][3],"@E 999999")+'        '+Transform(aEmpr4[2][4],"@E 999999");
+'        '+Transform(aEmpr4[2][5],"@E 999999")+'        '+Transform(aEmpr4[2][6],"@E 999999")+'        '+Transform(aEmpr4[2][7],"@E 999999")+'        '+Transform(aEmpr4[2][8],"@E 999999"),"170"} )
aAdd( aLogProc, {"1","1.11.3 - "+STR0176+"     -      "+Transform(aEmpr4[3][2],"@E 999999")+'        '+Transform(aEmpr4[3][3],"@E 999999")+'        '+Transform(aEmpr4[3][4],"@E 999999");
+'        '+Transform(aEmpr4[3][5],"@E 999999")+'        '+Transform(aEmpr4[3][6],"@E 999999")+'        '+Transform(aEmpr4[3][7],"@E 999999")+'        '+Transform(aEmpr4[3][8],"@E 999999"),"171"} )
aAdd( aLogProc, {"1","1.11.4 - "+STR0177+"     -      "+Transform(aEmpr4[4][2],"@E 999999")+'        '+Transform(aEmpr4[4][3],"@E 999999")+'        '+Transform(aEmpr4[4][4],"@E 999999");
+'        '+Transform(aEmpr4[4][5],"@E 999999")+'        '+Transform(aEmpr4[4][6],"@E 999999")+'        '+Transform(aEmpr4[4][7],"@E 999999")+'        '+Transform(aEmpr4[4][8],"@E 999999"),"172"} )
aAdd( aLogProc, {"1","1.11.5 - "+STR0178+"              -      "+Transform(aEmpr4[5][2],"@E 999999")+'        '+Transform(aEmpr4[5][3],"@E 999999")+'        '+Transform(aEmpr4[5][4],"@E 999999");
+'        '+Transform(aEmpr4[5][5],"@E 999999")+'        '+Transform(aEmpr4[5][6],"@E 999999")+'        '+Transform(aEmpr4[5][7],"@E 999999")+'        '+Transform(aEmpr4[5][8],"@E 999999"),"173"} )
aAdd( aLogProc, {"1","1.11.6 - "+STR0179+"     -      "+Transform(aEmpr4[6][2],"@E 999999")+'        '+Transform(aEmpr4[6][3],"@E 999999")+'        '+Transform(aEmpr4[6][4],"@E 999999");
+'        '+Transform(aEmpr4[6][5],"@E 999999")+'        '+Transform(aEmpr4[6][6],"@E 999999")+'        '+Transform(aEmpr4[6][7],"@E 999999")+'        '+Transform(aEmpr4[6][8],"@E 999999"),"174"} )
aAdd( aLogProc, {"1","1.11.7 - "+STR0180+"       -      "+Transform(aEmpr4[7][2],"@E 999999")+'        '+Transform(aEmpr4[7][3],"@E 999999")+'        '+Transform(aEmpr4[7][4],"@E 999999");
+'        '+Transform(aEmpr4[7][5],"@E 999999")+'        '+Transform(aEmpr4[7][6],"@E 999999")+'        '+Transform(aEmpr4[7][7],"@E 999999")+'        '+Transform(aEmpr4[7][8],"@E 999999"),"175"} )
aAdd( aLogProc, {"1","1.11.8 - "+STR0181+"        -      "+Transform(aEmpr4[8][2],"@E 999999")+'        '+Transform(aEmpr4[8][3],"@E 999999")+'        '+Transform(aEmpr4[8][4],"@E 999999");
+'        '+Transform(aEmpr4[8][5],"@E 999999")+'        '+Transform(aEmpr4[8][6],"@E 999999")+'        '+Transform(aEmpr4[8][7],"@E 999999")+'        '+Transform(aEmpr4[8][8],"@E 999999"),"176"} )
aAdd( aLogProc, {"1","1.11.9 - "+STR0182+"               -      "+Transform(aEmpr4[9][2],"@E 999999")+'        '+Transform(aEmpr4[9][3],"@E 999999")+'        '+Transform(aEmpr4[9][4],"@E 999999");
+'        '+Transform(aEmpr4[9][5],"@E 999999")+'        '+Transform(aEmpr4[9][6],"@E 999999")+'        '+Transform(aEmpr4[9][7],"@E 999999")+'        '+Transform(aEmpr4[9][8],"@E 999999"),"177"} )
aAdd( aLogProc, {"1","1.11.10- "+STR0183+"               -      "+Transform(aEmpr4[10][2],"@E 999999")+'        '+Transform(aEmpr4[10][3],"@E 999999")+'        '+Transform(aEmpr4[10][4],"@E 999999");
+'        '+Transform(aEmpr4[10][5],"@E 999999")+'        '+Transform(aEmpr4[10][6],"@E 999999")+'        '+Transform(aEmpr4[10][7],"@E 999999")+'        '+Transform(aEmpr4[10][8],"@E 999999"),"178"} )
aAdd( aLogProc, {"1",Replicate("-",130),"179"})
aAdd( aLogProc, {"1",STR0184,"180"} )//"1.12 - Motivos de Saida com pessoal com contrato a termo"        
aAdd( aLogProc, {"1",STR0193,"181"} )//"                                      Quadro Sup.   Quadro Med.    Quadro Int. Prof.Alt.Qual.   Prof.Semi. Prof.nao Qual. Prat\Aprend "
aAdd( aLogProc, {"1","1.12.1 - "+STR0185+"    -      "+Transform(aEmpr4[11][2],"@E 999999")+'        '+Transform(aEmpr4[11][3],"@E 999999")+'        '+Transform(aEmpr4[11][4],"@E 999999");
+'        '+Transform(aEmpr4[11][5],"@E 999999")+'        '+Transform(aEmpr4[11][6],"@E 999999")+'        '+Transform(aEmpr4[11][7],"@E 999999")+'        '+Transform(aEmpr4[11][8],"@E 999999"),"182"} )
aAdd( aLogProc, {"1","1.12.2 - "+STR0186+"  -      "+Transform(aEmpr4[12][2],"@E 999999")+'        '+Transform(aEmpr4[12][3],"@E 999999")+'        '+Transform(aEmpr4[12][4],"@E 999999");
+'        '+Transform(aEmpr4[12][5],"@E 999999")+'        '+Transform(aEmpr4[12][6],"@E 999999")+'        '+Transform(aEmpr4[12][7],"@E 999999")+'        '+Transform(aEmpr4[12][8],"@E 999999"),"183"} )
aAdd( aLogProc, {"1","1.12.3 - "+STR0187+"    -      "+Transform(aEmpr4[13][2],"@E 999999")+'        '+Transform(aEmpr4[13][3],"@E 999999")+'        '+Transform(aEmpr4[13][4],"@E 999999");
+'        '+Transform(aEmpr4[13][5],"@E 999999")+'        '+Transform(aEmpr4[13][6],"@E 999999")+'        '+Transform(aEmpr4[13][7],"@E 999999")+'        '+Transform(aEmpr4[13][8],"@E 999999"),"184"} )
aAdd( aLogProc, {"1","1.12.4 - "+STR0188+"  -      "+Transform(aEmpr4[14][2],"@E 999999")+'        '+Transform(aEmpr4[14][3],"@E 999999")+'        '+Transform(aEmpr4[14][4],"@E 999999");
+'        '+Transform(aEmpr4[14][5],"@E 999999")+'        '+Transform(aEmpr4[14][6],"@E 999999")+'        '+Transform(aEmpr4[14][7],"@E 999999")+'        '+Transform(aEmpr4[14][8],"@E 999999"),"185"} )
aAdd( aLogProc, {"1",Replicate("-",130),"186"})
aAdd( aLogProc, {"1",STR0189,"187"} )//"1.13 - Outros Motivos de Saida com pessoal com contrato permanente ou a termo"        
aAdd( aLogProc, {"1",STR0190+"   -      "+Transform(aEmpr4[15][2],"@E 999999")+'        '+Transform(aEmpr4[15][3],"@E 999999")+'        '+Transform(aEmpr4[15][4],"@E 999999");
+'        '+Transform(aEmpr4[15][5],"@E 999999")+'        '+Transform(aEmpr4[15][6],"@E 999999")+'        '+Transform(aEmpr4[15][7],"@E 999999")+'        '+Transform(aEmpr4[15][8],"@E 999999"),"188"} )


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AusTrab ³ Autor ³ Marcos Kato		      ³ Data ³   25.07.08    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ausencia de Trabalho												     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Portugal                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³           ³											 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AusTrab()

Local cQryAus	:=""
Local aAusTrab	:={}                    
Local nMotAF1	:=0,nMotAF2	:=0,nMotAF3	:=0,nMotAF4	:=0,nMotAF5	:=0,nMotAF6	:=0,nMotAF7	:=0
Local nMotAM1	:=0,nMotAM2	:=0,nMotAM3	:=0,nMotAM4	:=0,nMotAM5	:=0,nMotAM6	:=0,nMotAM7	:=0
Local nMotHF1	:=0,nMotHF2	:=0,nMotHF3	:=0,nMotHF4	:=0,nMotHF5	:=0,nMotHF6	:=0,nMotHF7	:=0
Local nMotHM1	:=0,nMotHM2	:=0,nMotHM3	:=0,nMotHM4	:=0,nMotHM5	:=0,nMotHM6	:=0,nMotHM7	:=0
Local nTpFARem  :=0,nTpFANRe:=0,nTpMARem  :=0,nTpMANRe:=0
Local nTpFHRem  :=0,nTpFHNRe:=0,nTpMHRem  :=0,nTpMHNRe:=0
cQryAus:=" SELECT RA_SEXO,COUNT(RCM_TIPOAF) TIPOAF,RCM_TIPOBS TIPOBS, R8_DURACAO"
cQryAus+=" FROM "+RETSQLNAME("SR8")+" SR8 "
cQryAus+=" INNER JOIN "+RETSQLNAME("RCM")+" RCM ON "
cQryAus+=" R8_TIPOAFA=RCM_TIPO "       
cQryAus+=" AND RCM.D_E_L_E_T_='' "
cQryAus+=" INNER JOIN "+RETSQLNAME("SRA")+" SRA ON "
cQryAus+=" R8_MAT=RA_MAT "       
cQryAus+=" AND RA_FILIAL='"+cParFilial+"' "
cQryAus+=" AND SRA.D_E_L_E_T_='' "
cQryAus+=" WHERE SUBSTRING(R8_DATA,1,4)='"+cParAnoBas+"' "
cQryAus+=" AND SR8.D_E_L_E_T_='' "    
cQryAus+=" GROUP BY RA_SEXO,RCM_TIPOBS, R8_DURACAO "    

cQryAus := ChangeQuery(cQryAus)

If Select("TRBAUS")>0
	DbSelectArea("TRBAUS")
	TRBAUS->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryAus),"TRBAUS",.F.,.T.)

DbSelectArea("TRBAUS")
TRBAUS->(dbGoTop())

If TRBAUS->(!Eof())
	Do While TRBAUS->(!Eof())
		//================================
		//Motivo de Ausencia - RCM_TIPOBS 
		//================================
		//1 Por acidente de trabalho	
		//2 Por doenca 
		//3 Por doenca profissional
		//4 Por suspensão disciplinar	
		//5 Por assistencia inadiável	
		//6 Por maternidade / paternidade
		//7 Outras casas	
		//================================
		If TRBAUS->RA_SEXO=="F"
			If TRBAUS->TIPOBS=="1"
				nMotAF1++           
				nMotHF1+=TRBAUS->R8_DURACAO*24           
			ElseIf TRBAUS->TIPOBS=="2"
				nMotAF2++
				nMotHF2+=TRBAUS->R8_DURACAO*24           							
			ElseIf TRBAUS->TIPOBS=="3"
				nMotAF3++ 
				nMotHF3+=TRBAUS->R8_DURACAO*24           							
			ElseIf TRBAUS->TIPOBS=="4"
				nMotAF4++	 
				nMotHF4+=TRBAUS->R8_DURACAO*24           						
			ElseIf TRBAUS->TIPOBS=="5"
				nMotAF5++	   
				nMotHF5+=TRBAUS->R8_DURACAO*24           						
			ElseIf TRBAUS->TIPOBS=="6"
				nMotAF6++
				nMotHF6+=TRBAUS->R8_DURACAO*24           							
			ElseIf TRBAUS->TIPOBS=="7"
				nMotAF7++           
				nMotHF7+=TRBAUS->R8_DURACAO*24           				
			Endif      
	        If TRBAUS->TIPOBS=="1"//Sem Pagamento
				nTpFANRe++  
				nTpFHNRe+=TRBAUS->R8_DURACAO*24
	        ElseIf TRBAUS->TIPOBS=="2"//Com Pagamento
				nTpFARem++ 			     
				nTpFHNRem+=TRBAUS->R8_DURACAO*24
			Endif
		Else     
			If TRBAUS->TIPOBS=="1"
				nMotAM1++
				nMotHM1+=TRBAUS->R8_DURACAO*24           										
			ElseIf TRBAUS->TIPOBS=="2" 
				nMotAM2++			    
				nMotHM2+=TRBAUS->R8_DURACAO*24           				
			ElseIf TRBAUS->TIPOBS=="3"
				nMotAM3++		   
				nMotHM3+=TRBAUS->R8_DURACAO*24           								
			ElseIf TRBAUS->TIPOBS=="4"
				nMotAM4++		
				nMotHM4+=TRBAUS->R8_DURACAO*24           								
			ElseIf TRBAUS->TIPOBS=="5"
				nMotAM5++
				nMotHM5+=TRBAUS->R8_DURACAO*24           										
			ElseIf TRBAUS->TIPOBS=="6"
				nMotAM6++
				nMotHM6+=TRBAUS->R8_DURACAO*24           										
			ElseIf TRBAUS->TIPOBS=="7"
				nMotAM7++
				nMotHM7+=TRBAUS->R8_DURACAO*24           										
			Endif
	        If TRBAUS->TIPOBS=="1"//Sem Pagamento
				nTpMANRe++  
				nTpMHNRe+=TRBAUS->R8_DURACAO*24
	        ElseIf TRBAUS->TIPOBS=="2"//Com Pagamento
				nTpMARem++ 			     
				nTpMHNRem+=TRBAUS->R8_DURACAO*24
			Endif
		Endif
		TRBAUS->(DbSkip())
	End
Endif
Aadd(aAusTrab,{"F","1.18.1"  ," "," "," "," "," ",nMotAM1,nMotAF1,nMotHM1,nMotHF1})//Acidente
Aadd(aAusTrab,{"F","1.18.2"  ," "," "," "," "," ",nMotAM2,nMotAF2,nMotHM2,nMotHF2})//Doenca
Aadd(aAusTrab,{"F","1.18.2.1"," "," "," "," "," ",nMotAM3,nMotAF3,nMotHM3,nMotHF3})//Doenca Profissional
Aadd(aAusTrab,{"F","1.18.3"  ," "," "," "," "," ",nMotAM4,nMotAF4,nMotHM4,nMotHF4})//Suspensao Disciplinar
Aadd(aAusTrab,{"F","1.18.4"  ," "," "," "," "," ",nMotAM5,nMotAF5,nMotHM5,nMotHF5})//Assistencia Inadiavel
Aadd(aAusTrab,{"F","1.18.5"  ," "," "," "," "," ",nMotAM6,nMotAF6,nMotHM6,nMotHF6})//maternidade\Paterniade
Aadd(aAusTrab,{"F","1.18.6"  ," "," "," "," "," ",nMotAM7,nMotAF7,nMotHM7,nMotHF7})//Outros
Aadd(aAusTrab,{"F","1.18.7"  ," "," "," "," "," ",nTpMARem+nTpMANRe,nTpFARem+nTpFANRe,nTpMHRem+nTpMHNRe,nTpFHRem+nTpFHNRe})//Total de Ausencias
Aadd(aAusTrab,{"F","1.18.7.1"," "," "," "," "," ",nTpMARem,nTpFARem,nTpMHRem,nTpFHRem})//Com Pagamento
Aadd(aAusTrab,{"F","1.18.7.2"," "," "," "," "," ",nTpMANRe,nTpFANRe,nTpMHNRe,nTpFHNRe})//Sem Pagamento

aAdd( aLogProc, {"1",Replicate("-",130),"260"})
aAdd( aLogProc, {"1",STR0194,"261"} )//"1.18 - Ausencias ao Trabalho"
aAdd( aLogProc, {"1","                                       "+STR0207+"     "+STR0208,"262"})
aAdd( aLogProc, {"1",STR0195+Transform(nMotAM1 ,"@E 999999")+"     "+Transform(nMotHM1,"@E 999999")+" "+STR0209,"263"})//Acidentes
aAdd( aLogProc, {"1","											  "+Transform(nMotAF1 ,"@E 999999")+"     "+Transform(nMotHF1,"@E 999999")+" "+STR0210,"264"})//Acidentes
aAdd( aLogProc, {"1",STR0196+Transform(nMotAM2 ,"@E 999999")+"     "+Transform(nMotHM2,"@E 999999")+" "+STR0209,"265"})//Doenca
aAdd( aLogProc, {"1","							                  "+Transform(nMotAF2 ,"@E 999999")+"     "+Transform(nMotHF2,"@E 999999")+" "+STR0210,"266"})//Doenca
aAdd( aLogProc, {"1",STR0197+Transform(nMotAM3 ,"@E 999999")+"     "+Transform(nMotHM3,"@E 999999")+" "+STR0209,"267"})//Doenca Profissional
aAdd( aLogProc, {"1","                                            "+Transform(nMotAF3 ,"@E 999999")+"     "+Transform(nMotHF3,"@E 999999")+" "+STR0210,"268"})//Doenca Profissional
aAdd( aLogProc, {"1",STR0198+Transform(nMotAM4 ,"@E 999999")+"     "+Transform(nMotHM4,"@E 999999")+" "+STR0209,"269"})//Suspensao Disciplinar
aAdd( aLogProc, {"1","                                            "+Transform(nMotAF4 ,"@E 999999")+"     "+Transform(nMotHF4,"@E 999999")+" "+STR0210,"270"})//Suspensao Disciplinar
aAdd( aLogProc, {"1",STR0199+Transform(nMotAM5 ,"@E 999999")+"     "+Transform(nMotHM5,"@E 999999")+" "+STR0209,"271"})//Assistencia Inadiavels
aAdd( aLogProc, {"1","                                            "+Transform(nMotAF5 ,"@E 999999")+"     "+Transform(nMotHF5,"@E 999999")+" "+STR0210,"272"})//Assistencia Inadiavels
aAdd( aLogProc, {"1",STR0200+Transform(nMotAM6 ,"@E 999999")+"     "+Transform(nMotHM6,"@E 999999")+" "+STR0209,"273"})//Maternidade\Paternidade
aAdd( aLogProc, {"1","                                            "+Transform(nMotAF6 ,"@E 999999")+"     "+Transform(nMotHF6,"@E 999999")+" "+STR0210,"274"})//Maternidade\Paternidade
aAdd( aLogProc, {"1",STR0201+Transform(nMotAM7 ,"@E 999999")+"     "+Transform(nMotHM7,"@E 999999")+" "+STR0209,"275"})//outros
aAdd( aLogProc, {"1","                                            "+Transform(nMotAF7 ,"@E 999999")+"     "+Transform(nMotHF7,"@E 999999")+" "+STR0210,"276"})//outros
aAdd( aLogProc, {"1"," ","270"}) 
aAdd( aLogProc, {"1",STR0203+Transform(nTpMARem+nTpMANRe,"@E 999999")+"     "+Transform(nTpMHRem+nTpMHNRe,"@E 999999")+" "+STR0209,"277"})//Total de Ausencias remuneradas
aAdd( aLogProc, {"1","                                            "+Transform(nTpFARem+nTpFANRe,"@E 999999")+"     "+Transform(nTpFHRem+nTpFHNRe,"@E 999999")+" "+STR0210,"278"})//Total de Ausencias remuneradas
aAdd( aLogProc, {"1",STR0204+Transform(nTpMARem,"@E 999999")+"     "+Transform(nTpMHNRe,"@E 999999")+" "+STR0209,"279"})//Total de Ausencias remuneradas
aAdd( aLogProc, {"1","                                            "+Transform(nTpFARem,"@E 999999")+"     "+Transform(nTpFHNRe,"@E 999999")+" "+STR0210,"280"})//Total de Ausencias remuneradas
aAdd( aLogProc, {"1",STR0205+Transform(nTpMANRe,"@E 999999")+"     "+Transform(nTpMHNRe,"@E 999999")+" "+STR0209,"281"})//Total de Ausencias nao remuneradas 
aAdd( aLogProc, {"1","                                            "+Transform(nTpFANRe,"@E 999999")+"     "+Transform(nTpFHNRe,"@E 999999")+" "+STR0210,"282"})//Total de Ausencias nao remuneradas

MsgRun(STR0206,STR0047, {||GravaRGN(aAusTrab)})//"Processando Ausencia Trabalho"
Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GravaRGN ³ Autor ³ Marcos Kato		      ³ Data ³   25.07.08    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os dados no Balanco Social								     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Portugal                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³           ³											 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GravaRGN(aDadRGN)
Local nRGN:=0

DbselectArea("RGN")
RGN->(DbSetOrder(1))
RGN->(DbGoTop())

For nRGN:=1 To Len(aDadRGN)                         
	If DbSeek(cParFilial+cParAnoBas+DTOS(DDATABASE)+Alltrim(aDadRGN[nRGN][1])+aDadRGN[nRGN][2]+Space(8-len(aDadRGN[nRGN][2]))+Alltrim(aDadRGN[nRGN][3]))
		RecLock("RGN",.F.)
	Else
		RecLock("RGN",.T.)
	Endif
	//==========================================================================================================
	//Balanco Social  - Emprego,Custo Pessoal,Higiene e Seguranca,Formacao Profissional,Inf.Social Compl.
	//==========================================================================================================
	RGN->RGN_FILIAL	:=cParFilial
	RGN->RGN_ANOBAS	:=cParAnoBas
	RGN->RGN_DATGER	:=dDATABASE
	RGN->RGN_USRGER :=__cUserID
	RGN->RGN_PASTA  :=aDadRGN[nRGN][1]
	RGN->RGN_ITEM   :=adadRGN[nRGN][2]
	RGN->RGN_SUBITE :=adadRGN[nRGN][3]
	RGN->RGN_DESCR  :=adadRGN[nRGN][4]
	RGN->RGN_PNTHRS :=Iif(Valtype(adadRGN[nRGN][5])=="C",Val(adadRGN[nRGN][5]),adadRGN[nRGN][5])
	RGN->RGN_LOCAL  :=adadRGN[nRGN][6]
	RGN->RGN_CODDOE :=adadRGN[nRGN][7]
	RGN->RGN_QTD1 	:=adadRGN[nRGN][8]
	RGN->RGN_QTD2 	:=adadRGN[nRGN][9]
	RGN->RGN_VLR1 	:=Round(adadRGN[nRGN][10],2)    
	RGN->RGN_VLR2 	:=Round(adadRGN[nRGN][11],2) 
	RGN->RGN_EMAIL	:=cParEmail
	RGN->(MsUnlock())
Next
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DeletaRGN ³ Autor ³ Marcos Kato		      ³ Data ³   25.07.08    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Deleta os dados do Balanco Social							     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Portugal                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³           ³											 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DeletaRGN(cAno)

DbselectArea("RGN")
RGN->(DbSetOrder(1))
RGN->(DbGoTop())
If DbSeek(cParFilial+cAno)
	Do While RGN->(!Eof()) .And. RGN->RGN_ANOBAS==cAno
		RecLock("RGN",.F.)
		RGN->RGN_USRDEL:=__cUserID
		RGN->RGN_DATDEL:=dDatabase
		DbDelete()
		RGN->(MsUnlock())     
		RGN->(DbSkip())
	End
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LogBalSoc³ Autor ³ Marcos Kato		      ³ Data ³   25.07.08    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Log da Geracao do Balanco Social de Portugal 					 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Portugal                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³           ³											 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LogBalSoc(aLogProc)

Local aGPEM780Tit:={},aGPEM780Log:={},aProcTitLog := {},aLogDesc := {}
Local nCont

aSort(aLogProc,,,{|x,y| x[1]+x[3] < y[1]+y[3] }) // coloca o log em ordem por tipo de ocorrencia             
aAdd( aLogProc, {"9",Replicate("=",130)                               ,""} )
aAdd( aLogProc, {"9",STR0211+ " " + Time() + "  "  + Dtoc( MsDate() ),""} )//"Final do Processo de Geracao"

For nCont := 1 To Len(aLogProc)
	aAdd(aLogDesc,aLogProc[nCont][2])
Next
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Adiciona Informacoes do Processamento no Log Geral           			³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdd( aProcTitLog       ,STR0212 )//	"Informacoes do Processo de Geracao do Balanco Social" 
aAdd( aGPEM780Tit		, aProcTitLog[1] )
aAdd( aGPEM780Log		, aLogDesc       )
MsAguarde( { || fMakeLog(aGPEM780Log,aGPEM780Tit,"",.T.,STR0002,STR0213,"M","P",,.F.) } ,STR0213) //"Log de Ocorrencias" 
	/*fMakeLog(	aLogFile 	,;	//Array que contem os Detalhes de Ocorrencia de Log
	aLogTitle	,;	//Array que contem os Titulos de Acordo com as Ocorrencias
	cPerg		,;	//Pergunte a Ser Listado
	lShowLog	,;	//Se Havera "Display" de Tela
	cLogName	,;	//Nome Alternativo do Log
	cTitulo		,;	//Titulo Alternativo do Log
	cTamanho	,;	//Tamanho Vertical do Relatorio de Log ("P","M","G")
	cLandPort	,;	//Orientacao do Relatorio ("P" Retrato ou "L" Paisagem )
	aRet		,;	//Array com a Mesma Estrutura do aReturn
	lAddOldLog	 ;	//Se deve Manter ( Adicionar ) no Novo Log o Log Anterior
	)*/
Return