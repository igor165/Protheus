#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLSMPR001()
Gera arquivo TXT, com informacoes do i-SIMP para (ANP)
Adaptação da função TSMPR001
@author Itamar Oliveira
@since 01/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------

Function DCLSMPR001()

Local i				:= 0
Local j				:= 0
Local cFilAtu		:= cFilAnt
Local oTempTMP
Local oTempTCO

Private aRegs		:= {}
Private aStruc 		:= {}
Private aOperInt  	:= {}	// Posicao 1 - Saldos Iniciais
							// Posicao 2 - Saldos Finais
							// Posicao 3 - Estoque em Terceiros
							// Posicao 4 - Estoque de Terceiros

Private cObs    	:= ""
Private cTxt    	:= ""
Private cPerg  		:= ""

Private dDataIni	:= CTOD("  /  /  ")
Private dDataFim	:= CTOD("  /  /  ")

// Variáveis para impressão
Private Tamanho   := "G"
Private Titulo    := "Relatorio de Logs de Erros da geracao do SIMP"
Private Limite    := 220
Private cDesc1    := PadC("Este programa tem como objetivo imprimir o relatorio de   ",74)
Private cDesc2    := PadC("log de erros de geracao do arquivo iSIMP para ANP        ",74)
Private cDesc3    := PadC("",74)
Private wnrel     := "CPR003"
Private nomeprog  := "TSMPR00"
Private nLastKey  :=  0
Private cString   := "SD2"
Private aReturn   := {"Branco",1,"Comercial",2,2,1,"",1}
Private li        :=  66
Private lContinua := .T.
Private m_pag     := 1
Private lMovi	  := .T.
Private lRecSD2   := .T.

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

MsgRun("Aguarde.... Validando dados iniciais para geracao do arquivo",, {|| lContinua := ValidaSIMP()})

If !lContinua
	Return Nil
EndIf

AADD(aStruc,{ "TIPO"    , "C" ,20, 0 })
AADD(aStruc,{ "DATA1"   , "D" ,8, 0 })
AADD(aStruc,{ "DOC"     , "C" ,TamSX3("D1_DOC")[1], 0 })
AADD(aStruc,{ "SERIE"   , "C" ,3, 0 })
AADD(aStruc,{ "OPERAC"  , "C" ,7, 0 })
AADD(aStruc,{ "COD"     , "C" ,15, 0 })
AADD(aStruc,{ "OBS"     , "C" ,100, 0 })
  
oTempTMP := FWTemporaryTable():New( "TMPDCL" )
oTempTMP:SetFields(aStruc)
oTempTMP:AddIndex("IndTMP", {"TIPO"} )
oTempTMP:Create()

//Tabela temporaria para gerar consolidado
aStruc := {}
AADD(aStruc,{ "D37_ARI"		,"C",010,0 })        
AADD(aStruc,{ "D37_MES"		,"C",002,0 })
AADD(aStruc,{ "D37_ANOREF"	,"C",004,0 })
AADD(aStruc,{ "D37_OPERAC"	,"C",007,0 })
AADD(aStruc,{ "D37_INST1"	,"C",007,0 })
AADD(aStruc,{ "D37_INST2"	,"C",007,0 })
AADD(aStruc,{ "D37_CODPRD"	,"C",009,0 })
AADD(aStruc,{ "D37_QTDPRD"	,"N",015,2 })
AADD(aStruc,{ "D37_QTDEKG"	,"N",015,2 })
AADD(aStruc,{ "D37_MODAL"	,"C",001,0 })
AADD(aStruc,{ "D37_VEICUL"	,"C",007,0 })
AADD(aStruc,{ "D37_TERCEI"	,"C",014,0 })
AADD(aStruc,{ "D37_MUNIC"	,"C",007,0 })
AADD(aStruc,{ "D37_ATIVEC"	,"C",005,0 })
AADD(aStruc,{ "D37_PAIS"	,"C",004,0 })
AADD(aStruc,{ "D37_LICIMP"	,"C",010,0 })
AADD(aStruc,{ "D37_DECIMP"	,"C",010,0 })
AADD(aStruc,{ "D37_NF"		,"C",007,0 })
AADD(aStruc,{ "D37_SERIE"	,"C",002,0 })
AADD(aStruc,{ "D37_DATAOP"	,"C",008,0 })
AADD(aStruc,{ "D37_SERVIC"	,"C",001,0 })
AADD(aStruc,{ "D37_CFISQU"	,"C",003,0 })
AADD(aStruc,{ "D37_METAFE"	,"C",003,0 })
//AADD(aStruc,{ "D37_UNMCFQ"	,"C",002,0 })
AADD(aStruc,{ "D37_MODFRT"	,"C",002,0 })
AADD(aStruc,{ "D37_VALOR"	,"C",010,0 })
AADD(aStruc,{ "D37_PROOPE"	,"C",009,0 })
AADD(aStruc,{ "D37_MASSA"	,"C",007,0 }) 
AADD(aStruc,{ "D37_RECGLP"	,"C",002,0 })
AADD(aStruc,{ "D37_IDENT"	,"C",005,0 })     
AADD(aStruc,{ "D37_CHVNFE"	,"C",044,0 })     

oTempTCO := FWTemporaryTable():New( "TCODCL" )
oTempTCO:SetFields(aStruc)
oTempTCO:AddIndex("IndTCO", {"D37_MES","D37_ANOREF","D37_INST1","D37_OPERAC","D37_CODPRD"} )
oTempTCO:Create()

cPerg := PadR("CPR001",Len(SX1->X1_GRUPO))  
AADD(aRegs,{cPerg,"01","Mes............... ?","","","mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Ano............... ?","","","mv_ch2","C",04,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Path Gravacao..... ?","","","mv_ch3","C",30,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Reprocessa Arquivo ?","","","mv_ch4","N",01,0,0,"C","","mv_par04","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"05","Produto De ....... ?","","","mv_ch5","C",15,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SB1","",""})
AADD(aRegs,{cPerg,"06","Produto Ate ...... ?","","","mv_ch6","C",15,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SB1","",""})
AADD(aRegs,{cPerg,"07","Poder Terceiros... ?","","","mv_ch7","N",01,0,0,"C","","mv_par07","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"08","Filial De ........ ?","","","mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"09","Filial Ate ....... ?","","","mv_ch9","C",02,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"10","Armazem De........ ?","","","mv_cha","C",02,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"11","Armazem Ate....... ?","","","mv_chb","C",02,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"12","TES não movim Estoq?","","","mv_chc","N",01,0,2,"C","","mv_par12","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If ! SX1->(DbSeek(cPerg+aRegs[i,2]))
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			EndIf
		Next
		MsUnlock()
	EndIf
Next 

If !Pergunte(cPerg,.T.)
	//Deletando o arquivo temporario - Consolidado
	oTempTCO:Delete()
	oTempTMP:Delete()
	Return
EndIf

// O mes de referencia nao pode ser menor que 11/2004
// O SIMP passou a funcionar apos esse mes
If (MV_PAR02 == "2004" .Or. MV_PAR02 == "04") .And. Val(MV_PAR01) < 11
	Alert("O Arquivo SIMP não será gerado. O mês escolhido deve ser maior que 10/2004.")
	
	//Deletando o arquivo temporario - Consolidado
	oTempTCO:Delete()
	oTempTMP:Delete()
	Return
EndIf

If !MV_PAR01 $ "01/02/03/04/05/06/07/08/09/10/11/12"
	Alert(" Mês informado incorreto: "+MV_PAR01)
	
	//Deletando o arquivo temporario - Consolidado
	oTempTCO:Delete()
	oTempTMP:Delete()
	Return
EndIf

If MV_PAR01=="12"
	dDataFim:=CTOD("01/"+"01/"+STR(VAL(MV_PAR02)+1,4)) - 1
Else
	dDataFim:=CTOD("01/"+StrZero(VAL(MV_PAR01)+1,2)+"/"+MV_PAR02)  - 1
EndIf

dDataIni:=CTOD("01/"+MV_PAR01+"/"+Substr(MV_PAR02,3,2))
cTxt    :=Alltrim(MV_PAR03)+Alltrim(GetMv("MV_CSIMPAR"))+MV_PAR01+Substr(MV_PAR02,3,2)+".TXT"

Processa({|| RunProc(oTempTMP,oTempTCO) }, "Processa")

cFilAnt := cFilAtu

//Deletando o arquivo temporario - Consolidado
oTempTCO:Delete()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RunProc()
Gera arquivo TXT, com informacoes do i-SIMP para (ANP)
@author Itamar Oliveira
@since 01/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function RunProc(oTempTMP,oTempTCO)

Local cAliasD37		:= ""
Private cCDSMP  	:= ""
Private cMassa		:= ""
Private cFilDe		:= ""
Private cFilAte		:= ""    
Private cOPSMP		:= ""
Private cInst 		:= GetMv("MV_INSTSIM")
Private cModal 		:= Space(01)
Private cVeiculo 	:= Space(07)
Private cPais 		:= Space(4)
Private cSerie 		:= Space(02)
Private cInst2 		:= Space(07)
Private cMunicTer 	:= Space(07)
Private cAtividTer 	:= Space(05)
Private cTerceiro 	:= Space(14)
Private cDataOp 	:= Space(08)
Private cOperacao	:= Space(07)
private cChDanfe    := Space(44)
Private aCarac		:= {}
Private aUnMed		:= {}
Private aMAfer		:= {}
Private aValor		:= {}
Private aClasse		:= {}
Private aAreaD37	:= {}
Private aOpTotal	:= {}
Private aOpera		:= {}
Private aProdut		:= {}
Private aQtde		:= {}
Private aQtdeKG		:= {}
Private aMassa		:= {}
Private aMassaEsp	:= {}
Private aInst		:= {}
Private aOpTotalTo	:= {}
Private aProdutTo	:= {}
Private aQtdeTo		:= {}
Private aFilial		:= {}
Private aFilialTo	:= {}
Private aQtdeKGTo	:= {}
Private aMassaTo	:= {}
Private aClasseTo	:= {}
Private aInstTo		:= {}
Private aIdent		:= {}
Private aAreaTer	:= {}
Private aAreaAnterior := {}
Private aAcerto		:= {}
Private nHdl 		:= 0
Private nIdent 		:= 0
Private nProc		:= 0
Private nProc2		:= 0   
Private nReg 		:= 0
Private lnLoop		:= .F.
Private lAchou 		:= .F.
Private lContTPL 	:= .T.
Private lFirst      := .T.

wnrel := SetPrInt(cString,wnrel,,Titulo,cDesc1,cDesc2,cDesc3,.F.,.F.,.F.,Tamanho,.F.)
If nLastKey == 27
	oTempTMP:Delete()
	Return
EndIf

SetDefault(aReturn,cString)
If nLastKey == 27
	oTempTMP:Delete()
	Return
EndIf

cCDSMP 	:= StrZero(Val(GetMv("MV_CSIMPAR")), 10) //Codigo SIMP do Distribuidor

cFilDe  := MV_PAR08
cFilAte := MV_PAR09

// Se for re-processamento. 
If MV_PAR04 == 1

	//Deleta registros do mes para processar e criar novos registros
	DbSelectArea("D37")
	DbSetOrder(1)

	If (TcSrvType ()<>"AS/400")

		cAliasD37	:=	GetNextAlias()

		BeginSql Alias cAliasD37
	
			SELECT 
				D37.D37_FILIAL, D37.D37_ARI, D37.D37_MES, D37.D37_ANOREF, D37.R_E_C_N_O_ AS REGISTRO
			FROM
				%table:D37% D37
			WHERE
				D37.D37_MES=%Exp:Alltrim(MV_PAR01)% AND
				D37.D37_ANOREF=%Exp:Alltrim(MV_PAR02)% AND		
				D37.%NotDel%
		EndSql
	
		DbSelectArea(cAliasD37)
		(cAliasD37)->(DbGoTop())

		DbSelectArea("D37")

		While (cAliasD37)->( !EoF())
			D37->( DbGoTo((cAliasD37)->REGISTRO) )
			RecLock("D37",.F.)
			dbDelete()
			MsUnlock()
			(cAliasD37)->( DbSkip())
		EndDo

		dbSelectArea(cAliasD37)  
		dbCloseArea()
		DbSelectArea("D37")

	ElseIf DbSeek(cFilDe+cCDSMP+MV_PAR01+MV_PAR02,.T.)
		While !Eof() .And. D37->D37_FILIAL >= cFilDe .And. D37->D37_FILIAL <= cFilAte .And.;
			D37->D37_ARI == cCDSMP
			If D37->D37_MES == MV_PAR01 .And. D37_ANOREF == MV_PAR02
				RecLock("D37",.F.)
				Delete
				MsUnlock()
			EndIf
			DbSkip()
			Loop
		Enddo
	EndIf
	
	ProcIni() //Processa saldos iniciais
            
	If lContTPL == .T.
		ProcSD1() //Processa notas de entrada
		ProcSD2() //Processa notas de saida
		ProcSD3() //Processa movimentos internos
		
		If MV_PAR07 == 1
			ProcSB6() //Processa poder de/em terceiros
		EndIf
		
		ProcTot() //Processa totalizadores por operação
		ProcFim() //Processa saldos finais         
	EndIf		
EndIf

If lContTPL == .T.         

	// Geracao do arquivo Texto para ANP
	DbSelectArea("D37")
	DbSetOrder(1)
	DbSeek(cFilDe+cCDSMP+MV_PAR01+MV_PAR02, .T.)

	If lMovi
		// Se achou algum registro do ARI e do mes e ano do parametro, gerar arquivo texto
		nHdl := FCreate(cTxt, 0)
		If nHdl == -1
			oTempTMP:Delete()
			MsgInfo("Ocorreu um erro na criacao do arquivo:"+cTxt)
			Return
		EndIf

		//Gera consolidado
		While ! Eof() .And. D37->D37_FILIAL >= cFilDe .And. D37->D37_FILIAL <= cFilAte
			If D37->(Deleted())
				dbSkip()
				Loop
			EndIf
			If D37->D37_MES <> MV_PAR01 .Or. D37->D37_ANOREF <> MV_PAR02
				dbSkip()
				Loop
			EndIf
			// Estou verificando a quantidade pois se for zero não deverá estar no txt, só se Saldos Inicial ou Final
			If D37->D37_QTDPRD == 0 .And. (D37->D37_OPERAC <> aOperInt[1] .And. D37->D37_OPERAC <> aOperInt[2])
				dbSkip()
				Loop
			EndIf
			dbSelectArea("TCODCL")
			dbSetOrder(1)
			If Right(D37->D37_OPERAC,3) == "998" .And. dbSeek(D37->D37_MES+D37->D37_ANOREF+D37_INST1+D37->D37_OPERAC+D37->D37_CODPRD)
				RecLock("TCODCL",.F.)
				TCODCL->D37_QTDPRD	+= D37->D37_QTDPRD
				TCODCL->D37_QTDEKG	+= D37->D37_QTDEKG
				MsUnlock()
			Else
				RecLock("TCODCL",.T.)
				TCODCL->D37_ARI	:= D37->D37_ARI
				TCODCL->D37_MES	:= D37->D37_MES
				TCODCL->D37_ANOREF	:= D37->D37_ANOREF
				TCODCL->D37_OPERAC	:= D37->D37_OPERAC
				TCODCL->D37_INST1	:= D37->D37_INST1
				TCODCL->D37_INST2	:= D37->D37_INST2
				TCODCL->D37_CODPRD	:= D37->D37_CODPRD
				TCODCL->D37_QTDPRD	:= D37->D37_QTDPRD
				TCODCL->D37_QTDEKG	:= D37->D37_QTDEKG
				TCODCL->D37_MODAL	:= D37->D37_MODAL
				TCODCL->D37_VEICUL	:= D37->D37_VEICUL
				TCODCL->D37_TERCEI	:= D37->D37_TERCEI
				TCODCL->D37_MUNIC	:= D37->D37_MUNIC
				TCODCL->D37_ATIVEC	:= D37->D37_ATIVEC
				TCODCL->D37_PAIS	:= D37->D37_PAIS
 				TCODCL->D37_LICIMP	:= D37->D37_LICIMP
				TCODCL->D37_DECIMP	:= D37->D37_DECIMP
				TCODCL->D37_NF		:= D37->D37_NF
				TCODCL->D37_SERIE	:= D37->D37_SERIE
				TCODCL->D37_DATAOP	:= D37->D37_DATAOP
				TCODCL->D37_SERVIC	:= D37->D37_SERVIC
				TCODCL->D37_CFISQU	:= D37->D37_CFISQU
				TCODCL->D37_METAFE	:= D37->D37_METAFE
				TCODCL->D37_MODFRT	:= D37->D37_MODFRT
				TCODCL->D37_VALOR	:= D37->D37_VALOR
				TCODCL->D37_PROOPE	:= D37->D37_PROOPE
				TCODCL->D37_MASSA	:= D37->D37_MASSA
				TCODCL->D37_RECGLP	:= D37->D37_RECGLP  
				TCODCL->D37_CHVNFE := D37->D37_CHVNFE
				MsUnlock()
			Endif
			dbSelectArea("D37")
			dbSkip()                           
		Enddo

		dbSelectArea("TCODCL")
		dbGoTop()				
		nContSeq:=0
		While ! Eof()
			 
			If nContSeq == 0
				// REGISTRO DE CONTROLE
				cLinha := Space(33) + CHR(13) + CHR(10)
				FWrite(nHdl, cLinha)
				nContSeq++
			EndIf
	                    
			cLinha := StrZero(nContSeq, 10)
			cLinha += D37_ARI
			cLinha += D37_MES+D37_ANOREF
			cLinha += D37_OPERAC
			cLinha += D37_INST1
			cLinha += D37_INST2
			cLinha += D37_CODPRD
			cLinha += StrZero(D37_QTDPRD,15)
			cLinha += Iif(D37_QTDEKG== 0,"000000000000000",StrZero(D37_QTDEKG,15))
			cLinha += D37_MODAL
			cLinha += D37_VEICUL
			cLinha += D37_TERCEI
			cLinha += D37_MUNIC
			cLinha += D37_ATIVEC
			cLinha += D37_PAIS
			cLinha += D37_LICIMP
			cLinha += D37_DECIMP
			cLinha += D37_NF
			cLinha += D37_SERIE
			cLinha += D37_DATAOP
			cLinha += D37_SERVIC
			cLinha += D37_CFISQU
			cLinha += D37_METAFE
		//	cLinha += D37_UNMCFQ
			cLinha += D37_MODFRT
			cLinha += D37_VALOR
			cLinha += D37_PROOPE
			cLinha += D37_MASSA
			cLinha += D37_RECGLP  
			cLinha += D37_CHVNFE
			cLinha += CHR(13) + CHR(10)
	
			FWrite(nHdl, cLinha)
		
			dbSelectArea("TCODCL")
			dbSkip()                           
			nContSeq++
		Enddo
		                 
		cLinha := "0000000000" + cCDSMP + MV_PAR01 + MV_PAR02 + StrZero(nContSeq, 7) + CHR(13) + CHR(10)
	 	FSeek(nHdl, 0, 0)
		FWrite(nHdl, cLinha)
		FClose(nHdl)
	
	EndIf
EndIf
	
// Imprime Log de Erros
RptStatus({|| RptDetail(oTempTMP,oTempTCO)})

Return
        
//-------------------------------------------------------------------
/*/{Protheus.doc} ProcIni()
Gera arquivo TXT, com informacoes do i-SIMP para (ANP)
@author Itamar Oliveira
@since 01/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcIni()

Local cCodAnt 	:= ""
Local lAntigo	:= .F.				
Local cFilCtrl  := cFilAnt
Local cSkpLoc	:= GetNewPar("MV_SKPLOSI", "")  
Local aSalTer := {}
Local nB9Qini := 0
Local nB9Qi2UM:= 0

lFirst := .T.

	// Processa Saldos Iniciais
	dbSelectArea("SB1")
	DbSelectArea("SB9")
	DbSetOrder(2) // B9_FILIAL+DTOS(B9_DATA)+B9_LOCAL
	ProcRegua(RecCount())
	If DbSeek(cFilDe+DTOS(dDataIni-1))
	
		While !Eof() .And. SB9->B9_FILIAL >= cFilDe .And. SB9->B9_FILIAL <= cFilAte 

			If SB9->B9_DATA <> (dDataIni-1)
				DbSkip()
				Loop
			EndIf

			If Alltrim(MV_PAR05) != ""
				If SB9->B9_COD < MV_PAR05 .Or. SB9->B9_COD > MV_PAR06
					DbSkip()
					Loop
				EndIf
			EndIf
			                           
			If Alltrim(MV_PAR10) != "" 			
				If SB9->B9_LOCAL < MV_PAR10 .Or. SB9->B9_LOCAL > MV_PAR11
					DbSkip()
					Loop
				EndIf
			Endif
	        
	   		If SB9->B9_FILIAL <> cFilAnt .or. lFirst
	   			lFirst  := .F.
				cFilAnt := SB9->B9_FILIAL
				cInst	:= GetNewPar("MV_INSTSIM", "")
				If Alltrim(cInst) == ""
					cObs := "Codigo da Instalação (MV_INSTSIM) não preenchido para a Filial: " + SB9->B9_FILIAL
					ErroSB9()
				EndIf
			Endif
			cSkpLoc	:= GetNewPar("MV_SKPLOSI", "")
			
			If !Empty(cSkpLoc) .And. SB9->B9_LOCAL$Alltrim(cSkpLoc)
				DbSkip()
				Loop
			EndIf
			
			SB1->(DbSeek(xFilial("SB1")+SB9->B9_COD))
  			If SB1->B1_MSBLQL == "1"
      			dbSelectArea("SB9")
         		dbSkip()
       			Loop
    		EndIf
	
			DH5->(DbSeek(xFilial("DH5")+SB9->B9_COD))
			DH5->(DbSetOrder(1))
	
			If Empty(DH5->DH5_CODSIM)
				DbSelectArea("SB9")
				DbSkip()
				Loop
			EndIf
					
			If SB9->B9_QINI < 0
				cObs := "Quantidade Negativa"
				ErroSB9()
			EndIf

			If DH5->(Fieldpos("DH5_SIMPAN")) <> 0 .And. !Empty(DH5->DH5_SIMPAN) // Código Simp do Produto - Antigo
				cCodAnt := DH5->DH5_SIMPAN
				lAntigo	:= .T.
			Else
				cCodAnt := ""
				lAntigo	:= .F.
			Endif			 
			// Busca saldo de terceiros no periodo anterior para deduzir do saldo inicial do periodo em processamento.
			aSalTer	:= SaldoTerc(SB9->B9_COD,SB9->B9_LOCAL,"D",dDataIni-1,SB9->B9_LOCAL,.T.,SB9->B9_COD,.T.)
			If len(aSalTer) > 0 
				nB9Qini := SB9->B9_QINI - aSalTer[1,2]
				nB9Qi2UM:= SB9->B9_QISEGUM - convum(SB9->B9_COD,aSalTer[1,2],0,2)
			Else
				nB9Qini := SB9->B9_QINI
				nB9Qi2UM:= SB9->B9_QISEGUM
			EndIf
			DbSelectArea("D37")
			DbSetOrder(2)
			If Empty(cObs) // Se nao deu nenhum erro, grava o registro			
             	If !lAntigo
					If D37->(DbSeek(xFilial("D37")+MV_PAR01+MV_PAR02+aOperInt[1]+StrZero(Val(DH5->DH5_CODSIM), 9)))
						//Ja existe um registro com esses dados 
						lAchou := .T.
						RecLock("D37",.F.)
					Else             
						lAchou := .F.
						RecLock("D37",.T.)
					EndIf
					
					D37->D37_FILIAL	:= SB9->B9_FILIAL 					// Filial
					D37->D37_ARI	:= cCDSMP 							// Codigo SIMP do ARI
					D37->D37_MES	:= MV_PAR01 						// Mes
					D37->D37_ANOREF	:= MV_PAR02 						// Ano
					D37->D37_OPERAC	:= aOperInt[1] 						// Operacao                         
					D37->D37_INST1	:= StrZero(Val(cInst), 7) 		    // Instalacao 1 (armazem)
					D37->D37_INST2	:= "0000000" 						// Instalacao 2 (armazem)
					D37->D37_CODPRD	:= StrZero(Val(DH5->DH5_CODSIM),9)  // Codigo SIMP do Produto					
                
					DbSelectArea("SB5")
					SB5->(DbSetOrder(1))
	
					SB5->(DbSeek(xFilial("SB5")+SB9->B9_COD))
					If lAchou
						If SB5->(Fieldpos("B5_CDCL1")) <> 0 .and. SB5->B5_CDCL1 <> 0 // Fator de conversão para a primeira unidade de medida
							If SB5->B5_TCDCL1 == "M"
								D37->D37_QTDPRD += Round((nB9Qini * SB5->B5_CDCL1),0)
							Else
								D37->D37_QTDPRD += Round((nB9Qini / SB5->B5_CDCL1),0)
							EndIf
						Else					
							D37->D37_QTDPRD += Round((nB9Qini),0)	// Qtde
						EndIf
	
						If DH5->(Fieldpos("DH5_CONVDC")) <> 0 // Fator de conversão para a terceira unidade de medida
							If DH5->DH5_TCONDC == "M" 
								D37->D37_QTDEKG	+= Round((nB9Qini * DH5->DH5_CONVDC),0)
							Else
								D37->D37_QTDEKG	+= Round((nB9Qini / DH5->DH5_CONVDC),0)
							EndIf
						Else					
							If SB9->B9_QISEGUM == 0
								D37->D37_QTDEKG	+= Round((nB9Qini),0)
							Else
								D37->D37_QTDEKG	+= Round((nB9Qi2UM),0)
							EndIf
						EndIf
					Else
						If SB5->(Fieldpos("B5_CDCL1")) <> 0 .and. SB5->B5_CDCL1 <> 0 // Fator de conversão para a primeira unidade de medida
							If SB5->B5_TCDCL1 == "M"
								D37->D37_QTDPRD := Round((nB9Qini * SB5->B5_CDCL1),0)
							Else                                                         
								D37->D37_QTDPRD := Round((nB9Qini / SB5->B5_CDCL1),0)
							EndIf
						Else					
							D37->D37_QTDPRD := Round((nB9Qini),0)	// Qtde	
						EndIf
						
						If DH5->(Fieldpos("DH5_CONVDC")) <> 0 // Fator de conversão para a terceira unidade de medida
							If DH5->DH5_TCONDCL == "M"
								D37->D37_QTDEKG	:= Round((nB9Qini * DH5->DH5_CONVDC),0) 
							Else
								D37->D37_QTDEKG	:= Round((nB9Qini / DH5->DH5_CONVDC),0) 
							EndIf
						Else					
							// A quantidade em KG devera ser extraida do campo de qtde da 2nd. Un. Medida
							D37->D37_QTDEKG	:= Round(IIf(nB9Qi2UM <= 0, (nB9Qini), (nB9Qi2UM)),0)
						EndIf
					EndIf
					
					D37->D37_MODAL	:= "0" 						// Modal
					D37->D37_VEICUL	:= "0000000" 				// Veiculo (Embarcacao)
					D37->D37_TERCEI	:= "00000000000000" 		// Codigo do Terceiro (Campo 12)
					D37->D37_MUNIC	:= "0000000" 				// Codigo do Municipio do Terceiro que foi identIficado no campo acima (12)
					D37->D37_ATIVEC	:= "00000" 					// Codigo da Atividade Economica do Agente economico identIficado no campo 12
					D37->D37_PAIS	:= "0000" 					// Codigo do Pais de importacao ou exportacao do produto
					D37->D37_LICIMP		:= "0000000000" 			// Numero da Licenca de Importacao
					D37->D37_DECIMP		:= "0000000000" 			// Numero da Declaracao de Importacao
					D37->D37_NF		:= "0000000" 				// Numero da NF
					D37->D37_SERIE	:= "00"						// Codigo SIMP da Serie da NF
					D37->D37_DATAOP	:= "00000000" 				// Data da emissao da NF
					D37->D37_SERVIC	:= "0" 						// Codigo do Servico Acordado (DUTOS)
					D37->D37_CFISQU	:= "000"		 			// Codigo da Caracteristica Fisico-Quimica do Produto
					D37->D37_METAFE	:= "000"					// Codigo do Metodo de Afericao utilizado para afericao da Car. Fis-Quim.
					D37->D37_MODFRT	:= "00"	
					D37->D37_VALOR	:= "0000000000" 			// Valor da Caracteristica Fis-Quim. Expresso na un. medida acima
					D37->D37_PROOPE	:= "000000000" 				// Codigo do produto quando Operacao de Transferencia ou Codigo da Operacao origem, quando operacao de devolucao
					// Esta sendo enviada a quantidade de massa especifica zerada para saldos iniciais e finais
					D37->D37_MASSA	:= "0000000"
					D37->D37_RECGLP	:= 	"00"					// Codigo do Recipiente utilizado em operacoes com botijoes de GLP
				    D37->D37_CHVNFE := "00000000000000000000000000000000000000000000" //Chave de Identificação DANFE
					D37->(MsUnlock())
				Else
					ProcAnt(DH5->DH5_CODSIM, SB9->B9_FILIAL, cCDSMP, cInst, SB9->B9_COD,;
							SB9->B9_QINI, SB9->B9_QISEGUM, cCodAnt)
				Endif
			EndIf
			cObs	:= ""
			lAchou 	:= .F.			
			DbSelectArea("SB9")
			DbSkip()
			IncProc("Processando Saldo Inicial")
		Enddo
	Else
		cObs := "Filial Inicial não encontrada ou data de fechamento ("+DTOC(dDataIni-1)+") não encontrada."
		Alert("Filial Inicial não encontrada ou data de fechamento ("+DTOC(dDataIni-1)+") não encontrada.")
		lContTPL := .F.
		ErroSB9()
		cObs := ""
	EndIf
	
cFilAnt := cFilCtrl

Return(lContTPL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcAnt()
Gera linhas do TXT, para acerto dos novos codigos SIMP dos produtos
@author Luciana Pires
@since 22/05/2007
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcAnt(cCodSIMP, cFilSB9, cCDSMP, cInst, cCodProd, nQuantSB9, nQtdKg, cCodAnt)

Local nX 		:= 1       
Local aDados 	:= {}
/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando o código antigo na tabela SB5 estiver preenchido, por orientação da ANP deverá ser seguido os seguintes passos:                   ³
//³1 - Declarar o estoque inicial do produto (Codigo Antigo) igual ao estoque final deste mesmo produto do mês anterior;                    ³
//³2 - Declarar o estoque inicial do produto (Codigo Novo) como zero;                                                                       ³
//³3 - Informar a saida do produto com Código Antigo através do codigo de operação 1062001 - saida por transferência de outro produto;      ³
//³4 - Informar a entrada do produto com Código Novo através do código de operação 1061001 - recebimento por transferência de outro produto;³
//³5 - Declarar estoque final do produto (Código Antigo) como zero.                                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
	DbSelectArea("D37")
	DbSetOrder(2)

	For nX:= 1 to 5
		aDados := {}

		Do Case
		Case nX == 1
			aadd(aDados,{cCodAnt,;
				cFilSB9,;
				cCDSMP,;
				cInst,;
				cCodProd,;
				nQuantSB9,;
				nQtdKg,;
				aOperInt[1]}) // Estoque Inicial produto cod. antigo
		Case nX == 2
			aadd(aDados,{cCodSIMP,;
				cFilSB9,;
				cCDSMP,;
				cInst,;
				cCodProd,;
				0,;
				0,;
				aOperInt[1]}) // Estoque Inicial produto cod. novo
		Case nX == 3
			aadd(aDados,{cCodAnt,;
				cFilSB9,;
				cCDSMP,;
				cInst,;
				cCodProd,;
				nQuantSB9,;
				nQtdKg,;
				"1062001"}) // Saida produto cod. antigo
		Case nX == 4
			aadd(aDados,{cCodSIMP,;
				cFilSB9,;
				cCDSMP,;
				cInst,;
				cCodProd,;
				nQuantSB9,;
				nQtdKg,;
				"1061001"}) // Entrada produto cod. novo
		Case nX == 5
			aadd(aDados,{cCodAnt,;
				cFilSB9,;
				cCDSMP,;
				cInst,;
				cCodProd,;
				0,;
				0,;
				aOperInt[2]}) // Estoque Final produto cod. antigo
		EndCase
			
		If D37->(DbSeek(xFilial("SB9")+MV_PAR01+MV_PAR02+aDados[1][8]+StrZero(Val(aDados[1][1]), 9)))
			//Ja existe um registro com esses dados 
			lAchou := .T.
			RecLock("D37",.F.)
		Else             
			lAchou := .F.
			RecLock("D37",.T.)
		EndIf
		
		D37->D37_FILIAL	:= aDados[1][2]		 				// Filial
		D37->D37_ARI	:= aDados[1][3] 					// Codigo SIMP do ARI
		D37->D37_MES	:= MV_PAR01 						// Mes
		D37->D37_ANOREF	:= MV_PAR02 						// Ano
		D37->D37_OPERAC	:= aDados[1][8] 					// Operacao                         
		D37->D37_INST1	:= StrZero(Val(aDados[1][4]), 7)   // Instalacao 1 (armazem)
		D37->D37_INST2	:= "0000000" 						// Instalacao 2 (armazem)
		D37->D37_CODPRD	:= StrZero(Val(aDados[1][1]),9)	// Codigo SIMP do Produto
                
		DbSelectArea("SB5")
		SB5->(DbSetOrder(1))

		SB5->(DbSeek(xFilial("SB5")+aDados[1][5]))
		If lAchou
			If SB5->(Fieldpos("B5_CDCL1")) <> 0 .and. SB5->B5_CDCL1 <> 0 // Fator de conversão para a primeira unidade de medida
				If SB5->B5_TCDCL1 == "M"
					D37->D37_QTDPRD += Round((aDados[1][6] * SB5->B5_CDCL1),0)
				Else
					D37->D37_QTDPRD += Round((aDados[1][6] / SB5->B5_CDCL1),0)
				EndIf
			Else					
				D37->D37_QTDPRD += Round((aDados[1][6]),0)	// Qtde
			EndIf

			If DH5->(Fieldpos("DH5_CONVDC")) <> 0 // Fator de conversão para a terceira unidade de medida
				If DH5->DH5_TCONDC == "M" 
					D37->D37_QTDEKG	+= Round((aDados[1][6] * DH5->DH5_CONVDC),0)
				Else
					D37->D37_QTDEKG	+= Round((aDados[1][6] / DH5->DH5_CONVDC),0)
				EndIf
			Else					
				If aDados[1][7] == 0
					D37->D37_QTDEKG	+= Round((aDados[1][6]),0)
				Else
					D37->D37_QTDEKG	+= Round((aDados[1][7]),0)
				EndIf
			EndIf
		Else
			If SB5->(Fieldpos("B5_CDCL1")) <> 0 .and. SB5->B5_CDCL1 <> 0 // Fator de conversão para a primeira unidade de medida
				If SB5->B5_TCDCL1 == "M"
					D37->D37_QTDPRD := Round((aDados[1][6] * SB5->B5_CDCL1),0)
				Else                                                         
					D37->D37_QTDPRD := Round((aDados[1][6] / SB5->B5_CDCL1),0)
				EndIf
			Else					
				D37->D37_QTDPRD := Round((aDados[1][6]),0)	// Qtde	
			EndIf
			
			If DH5->(Fieldpos("DH5_CONVDC")) <> 0 // Fator de conversão para a terceira unidade de medida
				If DH5->DH5_TCONDC == "M"
					D37->D37_QTDEKG	:= Round((aDados[1][6] * DH5->DH5_CONVDC),0)
				Else
					D37->D37_QTDEKG	:= Round((aDados[1][6] / DH5->DH5_CONVDC),0) 
				EndIf
			Else					
				// A quantidade em KG devera ser extraida do campo de qtde da 2nd. Un. Medida
				D37->D37_QTDEKG	:= Round((IIf(aDados[1][7] <= 0, (aDados[1][6]), (aDados[1][7]))),0)
			EndIf
		EndIf
					
		D37->D37_MODAL	:= "0" 						// Modal
		D37->D37_VEICUL	:= "0000000" 				// Veiculo (Embarcacao)
		D37->D37_TERCEI	:= "00000000000000" 		// Codigo do Terceiro (Campo 12)
		D37->D37_MUNIC	:= "0000000" 				// Codigo do Municipio do Terceiro que foi identIficado no campo acima (12)
		D37->D37_ATIVEC	:= "00000" 					// Codigo da Atividade Economica do Agente economico identIficado no campo 12
		D37->D37_PAIS	:= "0000" 					// Codigo do Pais de importacao ou exportacao do produto
		D37->D37_LICIMP	:= "0000000000" 			// Numero da Licenca de Importacao
		D37->D37_DECIMP	:= "0000000000" 			// Numero da Declaracao de Importacao
		D37->D37_NF		:= "0000000" 				// Numero da NF
		D37->D37_SERIE	:= "00"						// Codigo SIMP da Serie da NF
		D37->D37_DATAOP	:= "00000000" 				// Data da emissao da NF
		D37->D37_SERVIC	:= "0" 						// Codigo do Servico Acordado (DUTOS)
		D37->D37_CFISQU	:= "000"		 			// Codigo da Caracteristica Fisico-Quimica do Produto
		D37->D37_METAFE	:= "000"					// Codigo do Metodo de Afericao utilizado para afericao da Car. Fis-Quim.
	//	D37->D37_UNMCFQ	:= "00"						// Codigo da Unidade de Medida da Carac. Fis-Quim. do Produto
		D37->D37_MODFRT	:= "00"	
		D37->D37_VALOR	:= "0000000000" 			// Valor da Caracteristica Fis-Quim. Expresso na un. medida acima
		D37->D37_PROOPE	:= "000000000" 				// Codigo do produto quando Operacao de Transferencia ou Codigo da Operacao origem, quando operacao de devolucao
		// Esta sendo enviada a quantidade de massa especifica zerada para saldos iniciais e finais
		D37->D37_MASSA	:= "0000000"
		D37->D37_RECGLP	:= 	"00"					// Codigo do Recipiente utilizado em operacoes com botijoes de GLP
		D37->D37_CHVNFE := "00000000000000000000000000000000000000000000" //Chave de Identificação DANFE
 	    MsUnlock()
    Next
    
Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcSD1()
Gera arquivo TXT, com informacoes do i-SIMP para (ANP)
@author Luciana Pires
@since 01/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcSD1()

Local operEnt    :=""         
Local lAgRegulado:=.F.
Local cFilCtrl   := cFilAnt

lFirst := .T.

// Processa Notas de Entrada
DbSelectArea("SD1")
DbSetOrder(6)
ProcRegua(RecCount())
DbSeek(cFilDe+DTOS(dDataIni),.T.)

While !SD1->(Eof()) .And. SD1->D1_FILIAL >= cFilDe .And. SD1->D1_FILIAL <= cFilAte

	If SD1->D1_DTDIGIT < dDataIni .Or. SD1->D1_DTDIGIT > dDatafim
		SD1->(DbSkip())
		Loop
	EndIf

	//Tratamento para retirar a preh nota da tabela D37
	If Empty(SD1->D1_TES)
		SD1->(DbSkip())
		Loop
	EndIf
	
	If Alltrim(MV_PAR05) != ""
		If SD1->D1_COD < MV_PAR05 .Or. SD1->D1_COD > MV_PAR06
			SD1->(DbSkip())
			Loop
		EndIf
	EndIf
	
	If Alltrim(MV_PAR10) != ""
		If SD1->D1_LOCAL < MV_PAR10 .Or. SD1->D1_LOCAL > MV_PAR11
			SD1->(DbSkip())
			Loop
		EndIf
	Endif

	If SD1->D1_FILIAL <> cFilAnt  .or. lFirst
		lFirst  := .F.
		cFilAnt := SD1->D1_FILIAL
		cInst	:= GetNewPar("MV_INSTSIM", "")
		If Alltrim(cInst) == ""
			cObs := "Codigo da Instalação (MV_INSTSIM) não preenchido para a Filial: " + SD1->D1_FILIAL
			ErroSD1()
		EndIf
	Endif
	
	DH5->(DbSeek(xFilial("DH5")+SD1->D1_COD))
	If Empty(DH5->DH5_CODSIM)
		SD1->(DbSkip())
		Loop
	EndIf
	
	SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD))
    If SB1->B1_MSBLQL == "1"
       SD1->(DbSkip())
       Loop
    EndIf
    
	//Tem que trazer apenas o saldo inicial e final, que já está sendo executado pela funcao PROCSB6.
   If Posicione("SF4",1,xFilial("SF4")+SD1->D1_TES,"F4_PODER3") <> "N"
      SD1->(DbSkip())
      Loop
   EndIf
	lMovi := .T.
	lAgRegulado:=.F.
	nReg++
	
	// Codigo da instalacao 2 - Caso seja uma NF de devolucao, procurar
	// codigo na tabela de clientes. Caso contrario procurar na tabela
	// de fornecedores.
	// Campo 12 - Terceiro. Se nao possui codigo de instalacao, procurar
	// codigo ANP do cliente/fornecedor. Se nao possuir Codigo ANP,
	// procurar por CNPJ. Se nao existir mandar em branco.
	// Nao esta contemplando uma operacao com 3 empresas. Analisar
	// e customizar para cada caso.
	cInst2 		:= "0000000"
	cTerceiro 	:= "00000000000000"
	cMunicTer 	:= "0000000"
	cAtividTer 	:= "00000"

	If SD1->D1_TIPO $ "DB"
		If AI0->(DbSeek(xFilial("AI0")+SD1->D1_FORNECE+SD1->D1_LOJA)) // Instalacao de Saida do Produto
			If Alltrim(AI0->AI0_CODINS) <> ""
				lAgRegulado :=.T.
				cInst2      := StrZero(Val(AI0->AI0_CODINS),7)
				cTerceiro 	:= "00000000000000"
				cMunicTer 	:= "0000000"
				cAtividTer 	:= "00000"
			Else
				lAgRegulado :=.F.
				cInst2      := "0000000"
				SA1->(DbSeek(xFilial("SA1")+SD1->D1_FORNECE+SD1->D1_LOJA)) // Instalacao de Saida do Produto
				cTerceiro 	:= StrZero(Val(SA1->A1_CGC),14)
				cMunicTer 	:= StrZero(Val(AI0->AI0_MUNSI),7)
				cAtividTer 	:= StrZero(Val(AI0->AI0_ATVSI),5)
			EndIf
         EndIf
	Else
			If D30->(DbSeek(xFilial("D30")+SD1->D1_FORNECE+SD1->D1_LOJA)) // Instalacao de Saida do Produto
				If Alltrim(D30->D30_INSTSI) <> ""
					lAgRegulado   :=.T.
					cInst2        := StrZero(Val(D30->D30_INSTSI),7)
					cTerceiro 	:= "00000000000000"
					cMunicTer 	:= "0000000"
					cAtividTer 	:= "00000"
				ELSE
					lAgRegulado   :=.F.
					cInst2        := "0000000"
					SA2->(DbSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA)) // Instalacao de Saida do Produto
					cTerceiro 	:= StrZero(Val(SA2->A2_CGC),14)
					cMunicTer 	:= StrZero(Val(D30->D30_MUNSIM),7)
					cAtividTer 	:= StrZero(Val(D30->D30_ATVSIM),5)
				ENDIF
			EndIf
	EndIf
		
		// Nota de Devolucao de Produtos que fazem parte de Estruturas
		// nao sao processados como NFE, pois o template realiza a devolucao
		// no estoque dos itens da estrutura do produto gerando movimentacoes
		// Internas, sendo assim essas devolucoes serao processadas como MI (SD3)
				
		// Caso nao possua operacao SIMP cadastrada ou o TES nao atualize
		// estoque, nao sera processado. O codigo de Operacao e obrigatorio
		// e as operacoes que nao atualizam estoque nao sao transmitidas a ANP
		
		// O parametro MV_PAR12 = sim irá considerar as notas de entradas e saidas onde a TES não atualiza
		// estoque desde que tenha a operação SIMP para permitir demonstrar devoluções e reenvio de notas 
		// com intuito de correção de valores.
		
		//(A ANP instruiu o cliente para gerar notas sem mov de estoque) portanto 
		// notas com que não atualiza estoque mas com codigo simp 3030004 (NF emitida e não entrou no estoque 
		// ou 1010003 (NF mãe com entregas nas filhas) serão consideradas.
				
		If SF4->(DbSeek(xFilial("SF4")+SD1->D1_TES))
			If Empty(SF4->F4_COPSIMP)
				SD1->(DbSkip())
				Loop
			EndIf
			If SF4->F4_ESTOQUE == "N" .and. Iif(MV_PAR12==2,!AllTrim(SF4->F4_COPSIMP) $  ('30300041010003'),SD1->D1_TIPO<>"D")
				SD1->(DbSkip())
				Loop
			else
				IF lAgRegulado
					operEnt:=SF4->F4_COPSIMP // Agente regulado
				ELSE
					IF ! EMPTY(SF4->F4_OPANRE)
						operEnt:=SF4->F4_OPANRE // Agente nao regulado
					ELSE
						operEnt:=SF4->F4_COPSIMP // Agente regulado
					ENDIF
				ENDIF
			EndIf
		EndIf
		
		If SD1->D1_QUANT < 0
			cObs:="Quantidade Negativa"
			ErroSD1()
		EndIf

		DbSelectArea("DH4")
		DbSetOrder(1)
		MsSeek(xFilial("DH4")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM)
		
		// Validacao da Via transporte (Modal) Aquaviario
		If Alltrim(DH4->DH4_MODANP) == ""
			cModal 	 := "9" //Sem modal
			cVeiculo := "0000000"
		Else
			cModal 	 := Alltrim(Str(Val(DH4->DH4_MODANP)))
			cVeiculo := "0000000"
			If Val(cModal) == 4 .Or. Val(cModal) == 5 // 4-Aquaviario / 5-Dutoviario
				If Alltrim(DH4->DH4_CODEMB) <> ""
					cVeiculo := StrZero(Val(DH4->DH4_CODEMB), 7)
				EndIf
			EndIf
		EndIf
		
		// Codigo do Pais de Importacao
		If 	Left(Alltrim(SF4->F4_COPSIMP), 1) == "2" .And. ;
			Right(Alltrim(SF4->F4_COPSIMP), 3) != "998"
			If Alltrim(D30->D30_PAISIM) == ""
				cObs 	:= "Codigo ANP do Pais de importacao nao preenchido."
				ErroSD1()
			Else
				cPais 	:= StrZero(Val(D30->D30_PAISIM), 4)
			EndIf
		Else
			cPais := "0000"
		EndIf
		
		// Numero da Licenca de Importacao e Declaracao de Importacao
		If 	(SF4->F4_COPSIMP >= "2011001" .And. SF4->F4_COPSIMP <= "2011999") ;
			.And. Right(Alltrim(SF4->F4_COPSIMP	), 3) != "998" ;
			.And. (Alltrim(DH4->DH4_NLCIMP) == "" .Or. Alltrim(DH4->DH4_DECIMP) == "")
			If SF4->F4_COPSIMP <> '2011003'
				cObs := "Numero da Licenca ou Declaracao de Importacao nao preenchido."
				ErroSD1()
			EndIf
		EndIf
		
		//Serie da NF
		If Alltrim(SD1->D1_SERIE) $ "A"
			cSerie := StrZero(Val(GetMv("MV_SERIEA")),2)
		ElseIf 	Alltrim(SD1->D1_SERIE) $ "B"
			cSerie := StrZero(Val(GetMv("MV_SERIEB")),2)
		ElseIf 	Alltrim(SD1->D1_SERIE) $ "C"
			cSerie := StrZero(Val(GetMv("MV_SERIEC")),2)
		ElseIf 	Alltrim(SD1->D1_SERIE) $ "UNI" .Or. ;
			Alltrim(SD1->D1_SERIE) $ "U"   .Or. ;
			Alltrim(SD1->D1_SERIE) $ "1"
			cSerie := StrZero(Val(GetMv("MV_SERIEU")),2)
		ElseIf Alltrim(SD1->D1_SERIE) $ "E"
			cSerie := StrZero(Val(GetMv("MV_SERIEE")),2)
		Else
			cSerie := StrZero(Val(GetMv("MV_SERIEO")),2)
		EndIf
		
		// Campo 26 - Quando a Operacao for de Devolucao informar a
		// Operacao original que gerou a devolucao.
		// Quando a Operacao for de transferencia informar o codigo do Produto
		
		// Operacoes de Devolucao (Entradas)
		If SF4->F4_COPSIMP == "1011004" .Or. SF4->F4_COPSIMP == "1011005"
			// VERIfICAR O POSICIONAMENTO DO PONTEIRO
			aAreaAnterior := GetArea()
			DbSelectArea("SD2")
			DbSetOrder(1)
			
			If SD2->(DbSeek(SD1->(D1_FILIAL+D1_NFORI+D1_SERIORI)))
				If SF4->(DbSeek(xfilial('SF4')+SD2->D1_TES))
					cOperacao 	:= StrZero(Val(SF4->F4_COPSIMP), 7)
				Else
					cOperacao	:= "000000000"
				EndIf
			Else
				cOperacao := "000000000"
			EndIf
			RestArea(aAreaAnterior)
			// Operacoes de Transferencia
		ElseIf 	SF4->F4_COPSIMP == "1061001" .Or. SF4->F4_COPSIMP == "1061002" ;
			.Or. SF4->F4_COPSIMP == "1061003"
			cOperacao := DH5->DH5_CODSIM
		Else
			cOperacao := "000000000"
		EndIf
		
		/*
			Campo 28 - Recipiente GLP - Devera ser preenchido obrigatoriamente quando
			o Codigo de Operacao estiver definido no array aOprObrig da função CGlpObrig
		*/
		If AllTrim(DH5->DH5_CODSIM) $ "210202003|210202001|210202002|210203001|210203002|210201001|210201002|210201003" .And.;
		IIF(lAgRegulado,CGlpObrig(SF4->F4_COPSIMP),CGlpObrig(SF4->F4_OPANRE))
			If Alltrim(DH4->DH4_CODVGL) == ""
				cObs := "Codigo do Recipiente GLP nao preenchido. Campo obrigatorio para essa operacao"
				ErroSD1()
			Else
				cGLP := StrZero(Val(DH4->DH4_CODVGL), 2)
			EndIf
		Else
			cGLP := "00"
		EndIf
		
		cDataOp := StrZero(Day(SD1->D1_EMISSAO), 2)
		cDataOp := cDataOp + StrZero(Month(SD1->D1_EMISSAO), 2)
		cDataOp := cDataOp + Alltrim(Str(Year(SD1->D1_EMISSAO)))
		
		If Empty(cObs) // Se nao deu nenhum erro, gravar os dados
			//VerIficar se o registro atual ja existe no arquivo D37. Pode ser uma nota de devolucao ou
			//uma nota com precos dIferentes para o mesmo produto. Ex.: 500 L Gas. com um valor e 300 L com outro.
			//Pode vir na mesma nota o mesmo produto com o preco dIferente. Porem, no arquivo SIMP deve-se
			//apenas somar as quantidades.
			
			// Posiciona SFT para busca do campo FT_CHVNFE
			SFT->(DbSetOrder(1))	//FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_CLIFOR+FT_LOJA
			SFT->(dbSeek(SD1->D1_FILIAL+"E"+SD1->(D1_SERIE+D1_DOC+D1_FORNECE+D1_LOJA)))
			
			IF empty(SFT->FT_CHVNFE)
				DbSelectArea("D37")
				DbSetOrder(2) // D37_FILIAL+D37_MES+D37_ANOREF+D37_OPERAC+D37_CODPRD
				If D37->(DbSeek(SD1->D1_FILIAL+cCDSMP+MV_PAR01+MV_PAR02+StrZero(Val(Right(Alltrim(SD1->D1_DOC),7)),7)+cSerie+StrZero(Val(DH5->DH5_CODSIM), 9)))
					//Ja existe um registro com esses dados
					lAchou := .T.
					RecLock("D37",.F.)
				Else
					lAchou := .F.
					RecLock("D37",.T.)
				EndIf
			ELSE
				DbSelectArea("D37")
				DbSetOrder(3) // D37_FILIAL+D37_ARI+D37_MES+D37_ANOREF+D37_SERIE+D37_CODPRD+D37_CFISQU+D37_METAFE+D37_UNMCFQ+D37_VALOR
				If D37->(DbSeek(SD1->D1_FILIAL+cCDSMP+MV_PAR01+MV_PAR02+SFT->FT_CHVNFE+StrZero(Val(DH5->DH5_CODSIM), 9)))
					//Ja existe um registro com esses dados
					lAchou := .T.
					RecLock("D37",.F.)
				Else
					lAchou := .F.
					RecLock("D37",.T.)
				EndIf
			EndIf
			
			D37->D37_FILIAL	:= SD1->D1_FILIAL 							// Filial
			D37->D37_ARI	:= cCDSMP 									// Codigo SIMP do ARI
			D37->D37_MES	:= MV_PAR01 								// Mes
			D37->D37_ANOREF	:= MV_PAR02 								// Ano
			D37->D37_OPERAC	:= operEnt //SF4->F4_T_OPSIM 							// Operacao
			D37->D37_INST1	:= StrZero(Val(cInst), 7)					// Instalacao 1 (armazem)
			D37->D37_INST2	:= cInst2 									// Instalacao 2 (armazem)
			D37->D37_CODPRD	:= StrZero(Val(DH5->DH5_CODSIM), 9)  		// Codigo SIMP do Produto
			
			SB5->(DbSeek(xfilial('SB5')+SD1->D1_COD))
			
			If lAchou
				If SB5->(Fieldpos("B5_CDCL1")) <> 0 .and. SB5->B5_CDCL1 <> 0// Fator de conversão para a primeira unidade de medida
					If SB5->B5_TCDCL1 == "M"
						D37->D37_QTDPRD += Round((SD1->D1_QUANT * SB5->B5_CDCL1),0)
					Else
						D37->D37_QTDPRD += Round((SD1->D1_QUANT / SB5->B5_CDCL1),0)
					EndIf
				Else
					D37->D37_QTDPRD += Round((SD1->D1_QUANT),0)	// Qtde
				EndIf
				
				If SB5->(Fieldpos("B5_CONVDCL")) <> 0 // Fator de conversão para a terceira unidade de medida
					If DH5->DH5_TCONDC == "M"
						D37->D37_QTDEKG	+= Round((SD1->D1_QUANT * DH5->DH5_CONVDC),0)
					Else
						D37->D37_QTDEKG	+= Round((SD1->D1_QUANT / DH5->DH5_CONVDC),0)
					EndIf
				Else
					If SD1->D1_QTSEGUM == 0
						D37->D37_QTDEKG	+= Round((SD1->D1_QUANT),0)
					Else
						D37->D37_QTDEKG	+= Round((SD1->D1_QTSEGUM),0)
					EndIf
				EndIf
			Else
				If SB5->(Fieldpos("B5_CDCL1")) <> 0 .and. SB5->B5_CDCL1 <> 0 // Fator de conversão para a primeira unidade de medida
					If SB5->B5_TCDCL1 == "M"
						D37->D37_QTDPRD := Round((SD1->D1_QUANT * SB5->B5_CDCL1),0)
					Else
						D37->D37_QTDPRD := Round((SD1->D1_QUANT / SB5->B5_CDCL1),0)
					EndIf
				Else
					D37->D37_QTDPRD := Round((SD1->D1_QUANT),0)	// Qtde
				EndIf
				
				If DH5->(Fieldpos("DH5_CONVDC")) <> 0 // Fator de conversão para a terceira unidade de medida
					If DH5->DH5_TCONDC == "M"
						D37->D37_QTDEKG	:= Round((SD1->D1_QUANT * DH5->DH5_CONVDC),0)
					Else
						D37->D37_QTDEKG	:= Round((SD1->D1_QUANT / DH5->DH5_CONVDC),0)
					EndIf
				Else
					// A quantidade em KG devera ser extraida do campo de qtde da 2nd. Un. Medida
					D37->D37_QTDEKG	:= Round((IIf(SD1->D1_QTSEGUM <= 0, SD1->D1_QUANT, SD1->D1_QTSEGUM)),0)
				EndIf
			EndIf
			
			D37->D37_MODAL	:= cModal		   							// Modal
			D37->D37_VEICUL	:= cVeiculo 								// Veiculo (Embarcacao)
			D37->D37_TERCEI	:= cTerceiro 	 							// Codigo do Terceiro (Campo 12)
			D37->D37_MUNIC	:= cMunicTer 	   							// Codigo do Municipio do Terceiro que foi identIficado no campo acima (12)
			D37->D37_ATIVEC	:= cAtividTer 								// Codigo da Atividade Economica do Agente economico identIficado no campo 12
			D37->D37_PAIS		:= cPais 									// Codigo do Pais de importacao ou exportacao do produto
			D37->D37_LICIMP	:= StrZero(Val(DH4->DH4_NLCIMP),10) 	   		// Numero da Licenca de Importacao
			D37->D37_DECIMP	:= StrZero(Val(DH4->DH4_DECIMP),10) 			// Numero da Declaracao de Importacao
			D37->D37_NF		:= IIF(empty(SFT->FT_CHVNFE),StrZero(Val(Right(Alltrim(SD1->D1_DOC),7)),7),"0000000") 	// Numero da NF
			D37->D37_SERIE	:= IIF(empty(SFT->FT_CHVNFE),cSerie,"00")		// Codigo SIMP da Serie da NF
			D37->D37_DATAOP	:= cDataOp									// Data da emissao da NF
			D37->D37_SERVIC	:= StrZero(Val(DH4->DH4_SRVIMP),1) 		// Codigo do Servico Acordado (DUTOS)
			D37->D37_CFISQU	:= "000"		 	   						// Codigo da Caracteristica Fisico-Quimica do Produto
			D37->D37_METAFE	:= "000"			  						// Codigo do Metodo de Afericao utilizado para afericao da Car. Fis-Quim.
		//	D37->D37_UNMCFQ	:= "00"			  							// Codigo da Unidade de Medida da Carac. Fis-Quim. do Produto
			D37->D37_MODFRT	:= SimpFrete(alltrim(Posicione("SF1",1,xFilial("SD1")+SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_TIPO),"F1_TPFRETE")))			  			
			D37->D37_VALOR	:= "0000000000"    							// Valor da Caracteristica Fis-Quim. Expresso na un. medida acima
			D37->D37_PROOPE	:= cOperacao 	  							// Codigo do produto quando Operacao de Transferencia ou Codigo da Operacao origem, quando operacao de devolucao
			D37->D37_MASSA	:= Right("0000000" + Alltrim(StrTran(Transform(DH4->DH4_MASSA, "99999999.999"), ".", "")),7)	// Massa especIfica expressa em kg/m3 a 1 (uma) atmosfera
			D37->D37_RECGLP	:= cGLP			   							// Codigo do Recipiente utilizado em operacoes com botijoes de GLP
			D37->D37_CHVNFE := iif(!empty(SFT->FT_CHVNFE),SFT->FT_CHVNFE,'00000000000000000000000000000000000000000000')  //chvnfe
			MsUnlock()
		EndIf
		
		cObs	:= ""
		lAchou	:= .F.
		SD1->(DbSkip())
		IncProc("Processando Notas de Entrada. Registro: " + Str(nReg))
   Enddo
cFilAnt := cFilCtrl

Return()		
         
//-------------------------------------------------------------------
/*/{Protheus.doc} ProcSD2()
Gera arquivo TXT, com informacoes do i-SIMP para (ANP)
@author Itamar Oliveira
@since 01/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcSD2()

Local nConta     := 0    
Local operSai    := ""
Local lAgRegulado:=.F.
Local cFilCtrl   := cFilAnt
Local lRecDH3 	 := .F.  
Local cValor	 := '0000000'
Local cDclVUn    := SuperGetMV("MV_DCLVUN1",.F.,"210203001|210203002|210203003|210203004|210203005|320101001|320102001|320102002|420102004|420102006|420105001|420201001|420201001|620601004|810101001|810102004|820101001|820101012|820101013|820101029|820101033|820101034|")
Local nX         := 2

lFirst := .T.
	
	// Busca parâmetros adicionais para impressão do preço unitário
	Do While .T.
		If !Empty(SuperGetMv("MV_DCLVUN"+Str(nX,1),.F.," "))
			cDclVUn += SuperGetMv("MV_DCLVUN"+Str(nX,1))
			nX++
		Else
			Exit
		EndIf
	EndDo

	// Processa Notas de Saida
	DbSelectArea("SD2")
	DbSetOrder(5)
	ProcRegua(RecCount())
	DbSeek(cFilDe+DTOS(dDataIni),.T.)
	nReg := 0

	While !Eof() .And. SD2->D2_FILIAL >= cFilDe .And. SD2->D2_FILIAL <= cFilAte 

		If SD2->D2_EMISSAO < dDataIni .Or. SD2->D2_EMISSAO > dDatafim
			DbSkip()
			Loop
		EndIf
		If Alltrim(MV_PAR05) != ""
			If SD2->D2_COD < MV_PAR05 .Or. SD2->D2_COD > MV_PAR06
				DbSkip()
				Loop
			EndIf
		EndIf

		If Alltrim(MV_PAR10) != "" 				
			If SD2->D2_LOCAL < MV_PAR10 .Or. SD2->D2_LOCAL > MV_PAR11
				DbSkip()
				Loop
			EndIf
	    Endif
	    
   		If SD2->D2_FILIAL <> cFilAnt  .or. lFirst
   		    lFirst := .F.
			cFilAnt := SD2->D2_FILIAL
			cInst	:= GetNewPar("MV_INSTSIM", "")
			If Alltrim(cInst) == ""
				cObs := "Codigo da Instalação (MV_INSTSIM) não preenchido para a Filial: " + SD2->D2_FILIAL
				ErroSD2()
			EndIf			
		Endif
	    	
		DH5->(DbSeek(xFilial("DH5")+SD2->D2_COD))	
		// Valida preenchimento do codigo SIMP do produto
		If Empty(DH5->DH5_CODSIM)
			DbSelectArea("SD2")
			DbSkip()
			Loop
		EndIf
	
//Tem que trazer apenas o saldo inicial e final, que já está sendo executado pela funcao PROCSB6.
//Segundo a PB (BETE), tudo que for saida, precisa sim, contar no arquivo SIMP, portanto o trecho abaixo, estou comentando. 
//Segundo ANA, por último, precisa sim, desconsiderar notas que envolvam poder de terceiros

       If Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_PODER3") <> "N"
	      dbSkip()
	      Loop
	   EndIf
        lMovi := .T.
    	lAgRegulado:=.F.
		nReg++
		cObs := ""

		// Atualiza flag de geracao para 2 (Nao)
		// Esse flag serve para filtrar os dados no momento do cadastramento
		// dos laudos de qualidade. Somente para as vendas (NFS)
		
		DbSelectArea("DH3")
		DbSetOrder(2)
		If DH3->(DbSeek(cFilDe+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_ITEM,.T.))	
			
			RecLock("DH3",.F.)
				DH3->DH3_GEROU := "2"
			MsUnlock()
		Endif		 
		
		// Codigo de Instalacao 1 e 2   
		// Segundo site da ANP, na venda a instalacao 1 eh a instalacao de onde
		// o produto esta saindo e a instalacao 2 eh a instalacao onde o produto
		// ira entrar (instalacao do cliente)
 		// Codigo da instalacao 2 - Caso seja uma NF de devolucao, procurar
		// codigo na tabela de Fornecedores. Caso contrario procurar na tabela 
		// de clientes. 
		// Campo 12 - Terceiro. Se nao possui codigo de instalacao, procurar
		// codigo ANP do cliente/fornecedor. Se nao possuir Codigo ANP, 
		// procurar por CNPJ. Se nao existir mandar em branco.
		// Nao esta contemplando uma operacao com 3 empresas. Analisar
		// e customizar para cada caso.

		cInst2 		:= "0000000"  
		cTerceiro 	:= "00000000000000"
		cMunicTer 	:= "0000000"
		cAtividTer 	:= "00000"
		
	 	If SD2->D2_TIPO $ "DB"
			If D30->(DbSeek(xFilial("D30")+SD2->D2_CLIENTE+SD2->D2_LOJA)) // Instalacao de Saida do Produto
			   If Alltrim(D30->D30_INSTSI) <> ""
                  lAgRegulado   :=.T.
                  cInst2        := StrZero(Val(D30->D30_INSTSI),7)
				  cTerceiro 	:= "00000000000000"
				  cMunicTer 	:= "0000000"
				  cAtividTer 	:= "00000"
               ELSE   
                  lAgRegulado   :=.F.
                  cInst2        := "0000000"
                  SA2->(DbSeek(xFilial("SA2")+SD2->D2_CLIENTE+SD2->D2_LOJA)) // Instalacao de Saida do Produto
				  cTerceiro 	:= StrZero(Val(SA2->A2_CGC),14)
				  cMunicTer 	:= StrZero(Val(D30->D30_MUNSIM),7)
				  cAtividTer 	:= StrZero(Val(D30->D30_ATVSIM),5)
               ENDIF
			EndIf

		Else
			If AI0->(DbSeek(xFilial("AI0")+SD2->D2_CLIENTE+SD2->D2_LOJA)) // Instalacao de Saida do Produto
				If Alltrim(AI0->AI0_CODINS) <> ""
                    lAgRegulado :=.T.
                    cInst2      := StrZero(Val(AI0->AI0_CODINS),7)
				    cTerceiro 	:= "00000000000000"
				    cMunicTer 	:= "0000000"
				    cAtividTer 	:= "00000"
				Else 
                    lAgRegulado :=.F.
                    cInst2      := "0000000"
                    SA1->(DbSeek(xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA)) // Instalacao de Saida do Produto
				    cTerceiro 	:= StrZero(Val(SA1->A1_CGC),14)
				    cMunicTer 	:= StrZero(Val(AI0->AI0_MUNSI),7)
				    cAtividTer 	:= StrZero(Val(AI0->AI0_ATVSI),5)
				EndIf
			EndIf
		Endif
		If SD2->D2_EST = 'EX' .and. !lAgRegulado .and. (cMunicter == '0000000' .or. empty(cMunicter))
			dbSelectArea("SM0")
			MsSeek(cEmpAnt+iif(!empty(xfilial('SD2')),xfilial('SD2'),cFilant))
			While !Eof() .And. SM0->M0_CODIGO == cEmpAnt .And. SM0->M0_CODFIL == iif(!empty(xfilial('SD2')),xfilial('SD2'),cFilant)
				cMunicTer:=SM0->M0_CODMUN
				Exit
			EndDo
			//restaura SM0 com filial 
			dbgotop()
			MsSeek(cEmpAnt+cFilCtrl)
		EndIF		
		// Caso nao possua operacao SIMP cadastrada ou o TES nao atualize
		// estoque, nao sera processado. O codigo de Operacao e obrigatorio
		// e as operacoes que nao atualizam estoque nao sao transmitidas a ANP
		If SF4->(DbSeek(xFilial("SF4")+SD2->D2_TES))
			If Iif(MV_PAR12==2,Empty(SF4->F4_COPSIMP) .or. SF4->F4_ESTOQUE == "N",Empty(SF4->F4_COPSIMP))
				DbSelectArea("SD2")
				DbSkip()
				Loop
			else
			    IF lAgRegulado
                   operSai:=SF4->F4_COPSIMP // Agente regulado
			    ELSE
                   IF !EMPTY(SF4->F4_OPANRE)
                      operSai:=SF4->F4_OPANRE // Agente nao regulado
                   ELSE
                      operSai:=SF4->F4_COPSIMP // Agente regulado
                   ENDIF   
			    ENDIF
			EndIf
		EndIf
		
		SC5->(DbSeek(xFilial("SC5")+SD2->D2_PEDIDO))
        // Validacao da Via transporte (Modal) Aquaviario 
		If Alltrim(SC5->C5_MODANP) == ""
			cModal 	 := "9" //Sem Modal
		Else
			cModal	 := Alltrim(Str(Val(SC5->C5_MODANP)))
			cVeiculo := "0000000"
			If Val(cModal) == 4  // 4-Aquaviario 
				If Alltrim(SC5->C5_CODEMB) <> ""
					cVeiculo := StrZero(Val(SC5->C5_CODEMB), 7)
				EndIf
			EndIf
		EndIf

		// Codigo do Pais de Importacao
		If 	Left(Alltrim(SF4->F4_COPSIMP),1) == "2" .And. ;
			Right(Alltrim(SF4->F4_COPSIMP),3) != "998"
			If Alltrim(AI0->AI0_PAISI) == ""
				cObs := "Codigo ANP do Pais de exportacao nao preenchido."
				ErroSD2()
			Else
				cPais := StrZero(Val(AI0->AI0_PAISI),4)			
			EndIf
		Else
			cPais:="0000"
		EndIf
		
		//Serie da NF
		If Alltrim(SD2->D2_SERIE) $ "A"
			cSerie := StrZero(Val(GetMv("MV_SERIEA")),2)
		ElseIf 	Alltrim(SD2->D2_SERIE) $ "B"
			cSerie := StrZero(Val(GetMv("MV_SERIEB")),2)
		ElseIf 	Alltrim(SD2->D2_SERIE) $ "C"
			cSerie := StrZero(Val(GetMv("MV_SERIEC")),2)
		ElseIf 	Alltrim(SD2->D2_SERIE) $ "UNI" .Or. ;
				Alltrim(SD2->D2_SERIE) $ "U"   .Or. ;
				Alltrim(SD2->D2_SERIE) $ "1"
			cSerie := StrZero(Val(GetMv("MV_SERIEU")),2)
		ElseIf Alltrim(SD2->D2_SERIE) $ "E"
			cSerie := StrZero(Val(GetMv("MV_SERIEE")),2)
		Else
			cSerie := StrZero(Val(GetMv("MV_SERIEO")),2)
		EndIf

		// Valida preenchimento do codigo SIMP da Caracteristica
		// Fisico-Quimica do Produto e seleciona a Unidade de 
		// Medida padrao para a Caracteristica.
        If Alltrim(DH3->DH3_LAUDO) <> ""
			// Se achou o laudo eh necessario contar quantas linhas de caracteristicas
			// o produto em questao possui. Eh necessario enviar no arquivo todas as
			// caracteristicas. Se o produto possui 3 caracteristicas, sao 3 linhas 
			// a enviar com as caracteristicas dIferentes e os outros dados todos iguais
			DbSelectArea("DHE")
			DbSetOrder(1)
       		
       		If DHE->(DbSeek(xFilial("SD2")+SD2->D2_LAUDO))
	       		While DHE->DHE_LAUDO == SD2->D2_LAUDO
	       			IF DHE->DHE_CODPRO == SD2->D2_COD
						AADD(aCarac, StrZero(Val(DHE->DHE_CODCAR), 3))
						AADD(aUnMed, StrZero(Val(DHE->DHE_UNMEDI), 2))
						AADD(aMAfer, StrZero(Val(DHE->DHE_MAFER), 3))
						AADD(aValor, StrZero(Val(DHE->DHE_VALOR), 10))
					EndIf 
					DbSkip()
	       		Enddo
	    	Else
				AADD(aCarac, Replicate("0", 3))
				AADD(aUnMed, Replicate("0", 2))
				AADD(aMAfer, Replicate("0", 3))
				AADD(aValor, Replicate("0", 10))
			Endif 	    	
	    Else
			AADD(aCarac, Replicate("0", 3))
			AADD(aUnMed, Replicate("0", 2))
			AADD(aMAfer, Replicate("0", 3))
			AADD(aValor, Replicate("0", 10))
		EndIf
    	If AllTrim(DH5->DH5_CODSIM) $ cDclVUn
    		cValor := right("0000000"+alltrim(StrTRAN(Cvaltochar (transform(SD2->D2_PRCVEN,"@E 999.9999")),',','')),7)
    	Else 
    		cValor := Replicate("0", 7)
    	EndIf		
		// Campo 26 - Quando a Operacao for de Devolucao informar a
		// Operacao original que gerou a devolucao.
		// Quando a Operacao for de transferencia informar o codigo do Produto
		
 		// Operacoes de Devolucao (Saida)
		If SF4->F4_COPSIMP == "1012004" .Or. SF4->F4_COPSIMP == "1012005" 
			// Verificar o posicionamento do ponteiro
			aAreaAnterior := GetArea()
			DbSelectArea("SD1")
			DbSetOrder(1)

			If SD1->(DbSeek(SD2->(D2_FILIAL+D2_NFORI+D2_SERIORI)))
				If SF4->(DbSeek(xFilial("SF4")+SD1->D1_TES))
					cOperacao := StrZero(Val(SF4->F4_COPSIMP), 7)
				Else
					cOperacao := "000000000"
				EndIf 
				lRecDH3:=.T.                   
			Else                               
				cOperacao := "000000000"
				lRecDH3:=.F.
			EndIf
			RestArea(aAreaAnterior)
		// Operacoes de Transferencia
		Else
			cOperacao := "000000000"
		EndIf

		/*
			Campo 28 - Recipiente GLP - Devera ser preenchido obrigatoriamente quando
			o Codigo de Operacao estiver definido no array aOprObrig da função CGlpObrig
		*/
		If AllTrim(DH5->DH5_CODSIM) $ "210202003|210202001|210202002|210203001|210203002|210201001|210201002|210201003" .And.;
		IIF(lAgRegulado,CGlpObrig(SF4->F4_COPSIMP),CGlpObrig(SF4->F4_OPANRE))
			If Alltrim(SC5->C5_CODVGLP) == ""
				cObs := "Codigo do Recipiente GLP nao preenchido. Campo obrigatorio para essa operacao"
				ErroSD2()
			Else
				cGLP := StrZero(Val(SC5->C5_CODVGLP), 2)
			EndIf
		Else
			cGLP := "00"
		EndIf

		cDataOp := StrZero(Day(SD2->D2_EMISSAO), 2)
		cDataOp := cDataOp + StrZero(Month(SD2->D2_EMISSAO), 2)
		cDataOp := cDataOp + Alltrim(Str(Year(SD2->D2_EMISSAO)))

		DbSelectArea("D37")
		DbSetOrder(1)
		If Empty(cObs) // Se nao deu erro
			// Loop para caracteristicas fisico-quimicas do produto.
			// Caso o produto possua mais que uma caracteristica eh necessario 
			// enviar uma caract. por linha, repetindo os outros dados
     		nIdent++
			
			For nConta := 1 To Len(aCarac)
				// Notas de Saida
				
				//VerIficar se o registro atual ja existe no arquivo D37. Pode ser uma nota de devolucao ou
				//uma nota com precos dIferentes para o mesmo produto. Ex.: 500 L Gas. com um valor e 300 L com outro.
				//Pode vir na mesma nota o mesmo produto com o preco dIferente. Porem, no arquivo SIMP deve-se 
				//apenas somar as quantidades.

				// Posiciona SFT para busca do campo FT_CHVNFE
				SFT->(DbSetOrder(1))	//FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_CLIFOR+FT_LOJA
				SFT->(dbSeek(SD2->D2_FILIAL+"S"+SD2->(D2_SERIE+D2_DOC+D2_CLIENTE+D2_LOJA)))

				IF empty(SFT->FT_CHVNFE)
					DbSelectArea("D37")
					DbSetOrder(2) // D37_FILIAL+D37_MES+D37_ANOREF+D37_OPERAC+D37_CODPRD
					If D37->(DbSeek(SD2->D2_FILIAL+cCDSMP+MV_PAR01+MV_PAR02+StrZero(Val(Right(Alltrim(SD2->D2_DOC),7)),7)+cSerie+StrZero(Val(DH5->DH5_CODSIM), 9)+aCarac[nConta]+aMAfer[nConta]+Space(TamSx3('D37_UNMCFQ')[1])+aValor[nConta]))
						//Ja existe um registro com esses dados 						
						lAchou:=.T.
						RecLock("D37",.F.)
					Else             
						lAchou:=.F.
						RecLock("D37",.T.)
					EndIf
				ELSE
					DbSelectArea("D37")
					DbSetOrder(3) // D37_FILIAL+D37_ARI+D37_MES+D37_ANOREF+D37_SERIE+D37_CODPRD+D37_CFISQU+D37_METAFE+D37_UNMCFQ+D37_VALOR
					If D37->(DbSeek(SD2->D2_FILIAL+cCDSMP+MV_PAR01+MV_PAR02+SFT->FT_CHVNFE+StrZero(Val(DH5->DH5_CODSIM), 9)+aCarac[nConta]+aMAfer[nConta]+Space(TamSx3('D37_UNMCFQ')[1])+aValor[nConta]))
						//Ja existe um registro com esses dados 						
						lAchou:=.T.
						RecLock("D37",.F.)
					Else             
						lAchou:=.F.
						RecLock("D37",.T.)
					EndIf
				EndIf

					D37->D37_FILIAL	:= SD2->D2_FILIAL 							// Filial
					D37->D37_ARI	:= cCDSMP 									// Codigo SIMP do ARI
					D37->D37_MES	:= MV_PAR01 		   						// Mes
					D37->D37_ANOREF	:= MV_PAR02 								// Ano
					D37->D37_OPERAC	:= operSai  //SF4->F4_COPSIMP 							// Operacao
					D37->D37_INST1	:= StrZero(Val(cInst), 7)					// Instalacao 1 (armazem)
					D37->D37_INST2	:= cInst2 									// Instalacao 2 (armazem)
					D37->D37_CODPRD	:= StrZero(Val(DH5->DH5_CODSIM), 9)  		// Codigo SIMP do Produto

					SB5->(DbSeek(xFilial("SB5")+SD2->D2_COD))
					
					If lAchou
						If SB5->(Fieldpos("B5_CDCL1")) <> 0 .and. SB5->B5_CDCL1 <> 0// Fator de conversão para a primeira unidade de medida
							If SB5->B5_TCDCL1 == "M"
								D37->D37_QTDPRD += Round((SD2->D2_QUANT * SB5->B5_CDCL1),0)
							Else
								D37->D37_QTDPRD += Round((SD2->D2_QUANT / SB5->B5_CDCL1),0)
							EndIf
						Else					
							D37->D37_QTDPRD += Round((SD2->D2_QUANT),0)	// Qtde
						EndIf

						// VerIfica se existe o Fator de Conversão para o DCL - SIMP
						If DH5->(Fieldpos("DH5_CONVDC")) <> 0   
							If DH5->DH5_TCONDCL == "M"
								D37->D37_QTDEKG	+= Round((SD2->D2_QUANT * DH5->DH5_CONVDC),0)
							Else
								D37->D37_QTDEKG	+= Round((SD2->D2_QUANT / DH5->DH5_CONVDC),0)
							EndIf
						Else					
							If SD2->D2_QTSEGUM == 0
								D37->D37_QTDEKG	+= Round((SD2->D2_QUANT),0)
							Else
								D37->D37_QTDEKG	+= Round((SD2->D2_QTSEGUM),0)
							EndIf
						EndIf
					Else
						If SB5->(Fieldpos("B5_CDCL1")) <> 0 .and. SB5->B5_CDCL1 <> 0 // Fator de conversão para a primeira unidade de medida
							If SB5->B5_TCDCL1 == "M"
								D37->D37_QTDPRD := Round((SD2->D2_QUANT * SB5->B5_CDCL1),0)
							Else
							D37->D37_QTDPRD := Round((SD2->D2_QUANT / SB5->B5_CDCL1),0)
							EndIf
						Else					
							D37->D37_QTDPRD := Round((SD2->D2_QUANT),0)	// Qtde
						EndIf
                                                                  
						If DH5->(Fieldpos("DH5_CONVDC")) <> 0 // Fator de conversão para a terceira unidade de medida
							If DH5->DH5_TCONDCL == "M"
								D37->D37_QTDEKG	:= Round((SD2->D2_QUANT * DH5->DH5_CONVDC),0)
							Else
								D37->D37_QTDEKG	:= Round((SD2->D2_QUANT / DH5->DH5_CONVDC),0) 
							EndIf
						Else
							// A quantidade em KG devera ser extraida do campo de qtde da 2nd. Un. Medida
							D37->D37_QTDEKG	:= Round((IIf(SD2->D2_QTSEGUM <= 0, SD2->D2_QUANT, SD2->D2_QTSEGUM)),0)
						EndIf
					EndIf

					D37->D37_MODAL	:= cModal							// Modal
					D37->D37_VEICUL	:= cVeiculo 		   				// Veiculo (Embarcacao)
					D37->D37_TERCEI	:= cTerceiro 						// Codigo do Terceiro (Campo 12)
					D37->D37_MUNIC	:= cMunicTer 						// Codigo do Municipio do Terceiro que foi identIficado no campo acima (12)
					D37->D37_ATIVEC	:= cAtividTer 						// Codigo da Atividade Economica do Agente economico identIficado no campo 12
					D37->D37_PAIS		:= cPais 		   					// Codigo do Pais de importacao ou exportacao do produto
					D37->D37_LICIMP	:= "0000000000"	   					// Numero da Licenca de Importacao
					D37->D37_DECIMP	:= "0000000000"	  					// Numero da Declaracao de Importacao
					D37->D37_NF		:= IIF(empty(SFT->FT_CHVNFE),StrZero(Val(Right(Alltrim(SD2->D2_DOC),7)),7),"0000000") 	// Numero da NF
					D37->D37_SERIE	:= IIF(empty(SFT->FT_CHVNFE),cSerie,"00")		// Codigo SIMP da Serie da NF
					D37->D37_DATAOP	:= cDataOp 							// Data da emissao da NF
					D37->D37_SERVIC	:= "0" 								// Codigo do Servico Acordado (DUTOS)
					D37->D37_CFISQU	:= aCarac[nConta]					// Codigo da Caracteristica Fisico-Quimica do Produto
					D37->D37_METAFE	:= aMAfer[nConta]					// Codigo do Metodo de Afericao utilizado para afericao da Car. Fis-Quim.
					D37->D37_MODFRT	:= SimpFrete(alltrim(Posicione("SF2",1,xFilial("SD2")+SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_FORMUL+D2_TIPO),"F2_TPFRETE")))					
					D37->D37_VALOR	:= aValor[nConta] 					// Valor da Caracteristica Fis-Quim. Expresso na un. medida acima
					D37->D37_PROOPE	:= cOperacao 						// Codigo do produto quando Operacao de Transferencia ou Codigo da Operacao origem, quando operacao de devolucao
					D37->D37_MASSA	:= cValor							// o campo massa mudou para valor unitario (Pic 999,9999) sem virgula	
					D37->D37_RECGLP	:= cGLP			   					// Codigo do Recipiente utilizado em operacoes com botijoes de GLP
					D37->D37_CHVNFE := IIF(!EMPTY(SFT->FT_CHVNFE),SFT->FT_CHVNFE,'00000000000000000000000000000000000000000000')  //chvnfe
					If Len(aCarac) > 1 
						D37->D37_IDENT := Alltrim(Str(nIdent))
					Else
						nIdent--
					EndIf
									
				MsUnlock()
				If SB1->(Fieldpos('B1_X_DISCO')) <> 0 .and. SB1->B1_X_DISCO = 'S' //tratamento para dispensa de coleta sb1
					DbSelectArea("D37")
					Dbsetorder(2)
					If D37->(DbSeek(SD2->D2_FILIAL+MV_PAR01+MV_PAR02+'4030001'+StrZero(Val(DH5->DH5_CODSIM), 9)))
						//Ja existe um registro de dispensa de coleta para a filial mes ano produto 						
						RecLock("D37",.F.)
					Else             
						RecLock("D37",.T.)
					EndIf					
					D37->D37_FILIAL	:= xFilial("D37")
					D37->D37_ARI		:= cCDSMP 					// Codigo SIMP do ARI
					D37->D37_MES		:= MV_PAR01 				// Mes
					D37->D37_ANO		:= MV_PAR02 				// Ano
					D37->D37_OPERAC	:= '4030001'
					D37->D37_INST1	:= cInst					// Instalacao 1 (armazem)
					D37->D37_INST2	:= "0000000"				// Instalacao 2 (armazem)
					D37->D37_CODPRD	:= StrZero(Val(DH5->DH5_CODSIM), 9)  		// Codigo SIMP do Produto
					If SB5->(Fieldpos("B5_CDCL1")) <> 0 .and. SB5->B5_CDCL1 <> 0// Fator de conversão para a primeira unidade de medida
						If SB5->B5_TCDCL1 == "M"
							D37->D37_QTDPRD += Round((SD2->D2_QUANT * SB5->B5_CDCL1),0)
						Else
							D37->D37_QTDPRD += Round((SD2->D2_QUANT / SB5->B5_CDCL1),0)
						EndIf
					Else					
						D37->D37_QTDPRD += Round((SD2->D2_QUANT),0)	// Qtde
					EndIf
					If SB5->(Fieldpos("B5_CONVDCL")) <> 0   
						If SB5->B5_TCONDCL == "M"
							D37->D37_QTDEKG	+= Round((SD2->D2_QUANT * SB5->B5_CONVDCL),0)
						Else
							D37->D37_QTDEKG	+= Round((SD2->D2_QUANT / SB5->B5_CONVDCL),0)
						EndIf
					Else					
						If SD2->D2_QTSEGUM == 0
							D37->D37_QTDEKG	+= Round((SD2->D2_QUANT),0)
						Else
							D37->D37_QTDEKG	+= Round((SD2->D2_QTSEGUM),0)
						EndIf
					EndIf					
					D37->D37_MODAL	:= "0"						// Modal
					D37->D37_VEICUL	:= "0000000"				// Veiculo (Embarcacao)
					D37->D37_TERCEI	:= "00000000000000"			// Codigo do Terceiro (Campo 12)
					D37->D37_MUNIC	:= "0000000" 				// Codigo do Municipio do Terceiro que foi identIficado no campo acima (12)
					D37->D37_ATIVEC	:= "00000" 					// Codigo da Atividade Economica do Agente economico identIficado no campo 12
					D37->D37_PAIS	:= "0000" 					// Codigo do Pais de importacao ou exportacao do produto
					D37->D37_LICIMP	:= "0000000000"				// Numero da Licenca de Importacao
					D37->D37_DECIMP		:= "0000000000"				// Numero da Declaracao de Importacao
					D37->D37_NF		:= "0000000"				// Numero da NF
					D37->D37_SERIE	:= "00"						// Codigo SIMP da Serie da NF
					D37->D37_DATAOP	:= "00000000"				// Data da emissao da NF
					D37->D37_SERVIC	:= "0" 						// Codigo do Servico Acordado (DUTOS)
					D37->D37_CFISQU	:= "000"		 			// Codigo da Caracteristica Fisico-Quimica do Produto
					D37->D37_METAFE	:= "000"					// Codigo do Metodo de Afericao utilizado para afericao da Car. Fis-Quim.
					//D37->D37_UM_CFQ	:= "00"						// Codigo da Unidade de Medida da Carac. Fis-Quim. do Produto
					D37->D37_MODFRT	:= "00"					
					D37->D37_VALOR	:= "0000000000" 			// Valor da Caracteristica Fis-Quim. Expresso na un. medida acima
					D37->D37_PROOPE	:= "000000000"				// Codigo do produto quando Operacao de Transferencia ou Codigo da Operacao origem, quando operacao de devolucao
					D37->D37_MASSA  := "0000000"
					D37->D37_RECGLP	:= "00"						// Codigo do Recipiente utilizado em operacoes com botijoes de GLP
					D37->D37_CHVNFE := "00000000000000000000000000000000000000000000" //Chave DANFE
					MsUnlock()
				EndIf 				
			Next
			// Atualiza o flag para 1 (Sim)
			// Esse flag serve para filtrar os dados no momento do cadastramento
			// dos laudos de qualidade. Somente para as vendas (NFS)
			
			DbSelectArea("DH3")
			DbSetOrder(2)
			DH3->(DbSeek(cFilDe+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_ITEM,.T.))
			
		    If lRecDH3
		 	   RecLock("DH3",.F.)
			   DH3->DH3_GEROU := "1"
			   MsUnlock()
            EndIf
			aCarac		:= {} 
			aUnMed		:= {} 
			aMAfer		:= {} 
			aValor		:= {}
			aMassaEsp	:= {}
		EndIf
		cObs := ""
		DbSelectArea("SD2")
		DbSkip()
		IncProc("Processando Notas de Saída. Registro: " + Str(nReg))
	Enddo
cFilAnt := cFilCtrl
	
Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcSD3()
Gera arquivo TXT, com informacoes do i-SIMP para (ANP)
@author Itamar Oliveira
@since 01/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcSD3()

Local cFilCtrl  := cFilAnt 
Local cPROOPE	 
Local nRecSB1 
Local lREOP  := .F.
Local cSeek  

lFirst := .T.

	// Processa Movimentos Internos
	DbSelectArea("SD3")
	DbSetOrder(6)
	ProcRegua(RecCount())
	DbSeek(cFilDe+DTOS(dDataIni),.T.)                    
	nReg := 0

	While !SD3->(Eof()) .And. SD3->D3_FILIAL >= cFilDe .And. SD3->D3_FILIAL <= cFilAte 

		If SD3->D3_EMISSAO < dDataIni .Or. SD3->D3_EMISSAO > dDatafim
			SD3->(DbSkip())
			Loop
		EndIf
		
		If Alltrim(MV_PAR05) != ""
			If SD3->D3_COD < MV_PAR05 .Or. SD3->D3_COD > MV_PAR06
				SD3->(DbSkip())
				Loop
			EndIf
		EndIf
	
		If Alltrim(MV_PAR10) != "" 			
			If SD3->D3_LOCAL < MV_PAR10 .Or. SD3->D3_LOCAL > MV_PAR11
				SD3->(DbSkip())
				Loop
			EndIf
        Endif
        
   		If SD3->D3_FILIAL <> cFilAnt .or. lfirst
   		    lFirst  := .F.
			cFilAnt := SD3->D3_FILIAL
			cInst	:= GetNewPar("MV_INSTSIM", "")
			If Alltrim(cInst) == ""
				cObs := "Codigo da Instalação (MV_INSTSIM) não preenchido para a Filial: " + SD3->D3_FILIAL
				ErroSD3()
			EndIf
		Endif
        
		DH5->(DbSeek(SD3->D3_FILIAL+SD3->D3_COD))
		If Empty(DH5->DH5_CODSIM)
			DbSelectArea("SD3")
			DbSkip()
			Loop
		EndIf
		
		If SD3->D3_ESTORNO == "S"
			SD3->(DbSkip())
			Loop
		EndIf
		lREOP:=.F.
		cPROOPE:="000000000"		
		// Se nao for TM padrao Microsiga (499/999) utilizar codigo da operacao
		// SIMP informado no cadastro de TM
		If !SD3->D3_TM $ "499/999"  
			SF5->(DbSeek(xFilial("SF5")+SD3->D3_TM))
			If SF5->F5_COPSIMP == "0000000" .Or. Empty(SF5->F5_COPSIMP) .Or. SD3->D3_QUANT <= 0
				DbSelectArea("SD3")
				DbSkip()
				Loop
			Else
				cOPSMP := SF5->F5_COPSIMP
			EndIf
		Else
			// Se for operacao padrao microsiga (499/999), utilizar codigo de 
			// Operacao SIMP cadastrado na tabela IB, de acordo com o definido
			// pelo usuario.
			If !(SX5->(DbSeek(SD3->D3_FILIAL+"IB"+"I"+SD3->D3_CF))) .Or. SD3->D3_QUANT <= 0
				DbSelectArea("SD3")
				DbSkip()
				Loop
			Else
				cOPSMP := Substr(SX5->X5_DESCRI,1,7)
			EndIf
			If SubStr(SD3->D3_CF,1,2) = 'RE' .And. SD3->D3_OP <> ' ' .and. cOPSMP = '1022015' 
				DbSelectArea('SC2')
				DbSetOrder(1)
				If SC2->(DbSeek(xFilial('SC2')+SD3->D3_OP))
					nRecSB1:= SB1->(recno())
					SB1->(DbSeek(xFilial('SB1')+SC2->C2_PRODUTO))
					cPROOPE:=DH5->DH5_CODSIM
					SB1->(Dbgoto(nRecSB1))
					lREOP := .T.
				EndIf
			EndIf				
		EndIf
		lMovi := .T.
		nReg++
		
		If SD3->D3_TM > "500"
			If SD3->(Fieldpos("D3_T_TIPO"))<>0 .And. SD3->D3_T_TIPO $ "DB"		
				If D30->(DbSeek(xFilial("D30")+SD3->D3_CODFOR+SD3->D3_LOJAFOR))
					If Alltrim(D30->D30_INSTSI) <> ""   
						cInst2 := StrZero(Val(D30->D30_INSTSI),7)
					Else
						cInst2 := "0000000"
					EndIf
				Else
					cInst2 := "0000000"
				Endif
			Else
				If AI0->(DbSeek(xFilial("AI0")+SD3->D3_CODFOR+SD3->D3_LOJAFOR))
					If Alltrim(AI0->AI0_CODINS) <> ""   
						cInst2 := StrZero(Val(AI0->AI0_CODINS),7)
					Else				
						cInst2 := "0000000"	
					EndIf
				Else
					cInst2 := "0000000"									
				Endif
			Endif
	    Else
			If SD3->(Fieldpos("D3_T_TIPO"))<>0 .And. SD3->D3_T_TIPO $ "DB"		
				If AI0->(DbSeek(xFilial("AI0")+SD3->D3_CODFOR+SD3->D3_LOJAFOR))
					If Alltrim(AI0->AI0_CODINS) <> ""   
						cInst2 := StrZero(Val(AI0->AI0_CODINS),7)
					Else
						cInst2 := "0000000"
					EndIf
				Else
					cInst2 := "0000000"		
				Endif
			Else
				If SA2->(DbSeek(xFilial('SA2')+SD3->D3_CODFOR+SD3->D3_LOJAFOR))
					If Alltrim(SA2->A2_T_INST) <> ""   
						cInst2 := StrZero(Val(SA2->A2_T_INST),7)
					Else
						cInst2 := "0000000"
					EndIf
				Else
					cInst2 := "0000000"		
				Endif			
			Endif			
		Endif
		
		cDataOp := StrZero(Day(SD3->D3_EMISSAO), 2)
		cDataOp := cDataOp + StrZero(Month(SD3->D3_EMISSAO), 2)
		cDataOp := cDataOp + Alltrim(Str(Year(SD3->D3_EMISSAO)))
                                                                                          
		DbSelectArea("D37")
		DbSetOrder(1)

		If Empty(cObs) // Se nao deu erro

			DbSelectArea("D37")
			DbSetOrder(2) // D37_FILIAL+D37_MES+D37_ANOREF+D37_OPERAC+D37_CODPRD
			// Tirado o agupamento para o D3, pois ele soma no item que veio do D2. 
			//Se agrupasse, levaria a operacao do D2 e ficaria errado

			D37->(DbSetOrder(5)) //D37_FILIAL+D37_ARI+D37_MES+D37_ANOREF+D37_OPERAC+D37_INST1+D37_INST2+D37_CODPRD
			IF lREOP
				cSeek := SD3->D3_FILIAL+cCDSMP+MV_PAR01+MV_PAR02+cOPSMP+StrZero(Val(cInst), 7)+StrZero(Val(cInst2), 7)+StrZero(Val(DH5->DH5_CODSIM), 9)
				D37->(DbSeek(cSeek))
				lAchou := .F.
				while cSeek == D37->(D37_FILIAL+D37_ARI+D37_MES+D37_ANOREF+D37_OPERAC+D37_INST1+D37_INST2+D37_CODPRD) 	
					If D37->D37_PROOPE == alltrim(cPROOPE) .and. D37->D37_DATAOP == cDataOp	
						If Iif(SD3->(Fieldpos("D3_MODAL"))<>0 .And. !Empty(SD3->D3_MODAL),Iif(D37->D37_MODAL=SD3->D3_MODAL,.T.,.F.),.T.)				// ?? Modal
							lAchou:=.T.
							Exit
						else						
							lAchou:=.F.
						EndIf
					EndIf 
					D37->(DBSKIP())
				EndDo
				If lAchou
					RecLock("D37",.F.)
				else						
					RecLock("D37",.T.) 
				EndIf
			Else
				//D37_FILIAL+D37_ARI+D37_MES+D37_ANOREF+D37_OPERAC+D37_INST1+D37_INST2+D37_CODPRD
				If D37->(DbSeek(SD3->D3_FILIAL+cCDSMP+MV_PAR01+MV_PAR02+cOPSMP+StrZero(Val(cInst), 7)+StrZero(Val(cInst2), 7)+StrZero(Val(DH5->DH5_CODSIM), 9)))
					If Iif(SD3->(Fieldpos("D3_T_MODAL"))<>0 .And. !Empty(SD3->D3_T_MODAL),Iif(D37->D37_MODAL=SD3->D3_T_MODAL,.T.,.F.),.T.)				// ?? Modal
						RecLock("D37",.F.)
						lAchou:=.T.
					else						
						RecLock("D37",.T.)
						lAchou:=.F.
					EndIf
				Else 
				   	RecLock("D37",.T.)
					lAchou:=.F.
				EndIf 
			EndIf			
			D37->D37_FILIAL	:= SD3->D3_FILIAL							// Filial
			D37->D37_ARI	:= cCDSMP 									// Codigo SIMP do ARI
			D37->D37_MES	:= MV_PAR01 								// Mes
			D37->D37_ANOREF	:= MV_PAR02 								// Ano
			D37->D37_OPERAC	:= cOPSMP		 	   						// Operacao
			D37->D37_INST1	:= StrZero(Val(cInst), 7)					// Instalacao 1 (armazem)
			D37->D37_INST2	:= StrZero(Val(cInst2), 7)				// ?? Instalacao 2 (armazem) (Onde achar na Mov. Int)
			D37->D37_CODPRD	:= StrZero(Val(DH5->DH5_CODSIM), 9)  		// Codigo SIMP do Produto
		
			SB5->(DbSeek(xFilial("SB5")+SD3->D3_COD),.T.)
			
			If lAchou
				If SB5->(Fieldpos("B5_CDCL1")) <> 0 .and. SB5->B5_CDCL1 <> 0 // Fator de conversão para a primeira unidade de medida
					If SB5->B5_TCDCL1 == "M"
						D37->D37_QTDPRD += Round((SD3->D3_QUANT * SB5->B5_CDCL1),0)
					Else   	
						D37->D37_QTDPRD += Round((SD3->D3_QUANT / SB5->B5_CDCL1),0)
					EndIf
				Else					
					D37->D37_QTDPRD += Round((SD3->D3_QUANT),0)	// Qtde
				EndIf
                                                          
				If DH5->(Fieldpos("DH5_CONVDC")) <> 0 // Fator de conversão para a terceira unidade de medida
					If DH5->DH5_TCONDCL == "M"
						D37->D37_QTDEKG	+= Round((SD3->D3_QUANT * DH5->DH5_CONVDC),0)
					Else
						D37->D37_QTDEKG	+= Round((SD3->D3_QUANT / DH5->DH5_CONVDC),0)
					EndIf
				Else
					If SD3->D3_QTSEGUM == 0
						D37->D37_QTDEKG	+= Round((SD3->D3_QUANT),0)
					Else
						D37->D37_QTDEKG	+= Round((SD3->D3_QTSEGUM),0)
					EndIf
				EndIf
			Else
				If SB5->(Fieldpos("B5_CDCL1")) <> 0.and. SB5->B5_CDCL1 <> 0   // Fator de conversão para a primeira unidade de medida
					If SB5->B5_TCDCL1 == "M"
						D37->D37_QTDPRD := Round((SD3->D3_QUANT * SB5->B5_CDCL1),0)
					Else
						D37->D37_QTDPRD := Round((SD3->D3_QUANT / SB5->B5_CDCL1),0)
					EndIf
				Else					
					D37->D37_QTDPRD := Round((SD3->D3_QUANT),0)	// Qtde
				EndIf
				
				If DH5->(Fieldpos("DH5_CONVDC")) <> 0 // Fator de conversão para a terceira unidade de medida   
					If DH5->DH5_TCONDCL == "M"
						D37->D37_QTDEKG	:= Round((SD3->D3_QUANT * DH5->DH5_CONVDC),0) 
					Else
						D37->D37_QTDEKG	:= Round((SD3->D3_QUANT / DH5->DH5_CONVDC),0) 
					EndIf
				Else
					// A quantidade em KG devera ser extraida do campo de qtde da 2nd. Un. Medida
					D37->D37_QTDEKG	:= Round((IIf(SD3->D3_QTSEGUM <= 0, SD3->D3_QUANT, SD3->D3_QTSEGUM)),0)
				EndIf
			EndIf
			D37->D37_MODAL	:= Iif(SD3->(Fieldpos("D3_MODAL"))<>0 .And. !Empty(SD3->D3_MODAL),Alltrim(Str(Val(SD3->D3_MODAL))),"0")							// ?? Modal
			D37->D37_VEICUL	:= "0000000"					// ?? Veiculo (Embarcacao)
			D37->D37_TERCEI	:= "00000000000000"				// ?? Codigo do Terceiro (Campo 12)
			D37->D37_MUNIC	:= "0000000" 					// ?? Codigo do Municipio do Terceiro que foi identIficado no campo acima (12)
			D37->D37_ATIVEC	:= "00000" 						// ?? Codigo da Atividade Economica do Agente economico identIficado no campo 12
			D37->D37_PAIS	:= "0000" 						// Codigo do Pais de importacao ou exportacao do produto
			D37->D37_LICIMP	:= "0000000000"					// Numero da Licenca de Importacao
			D37->D37_DECIMP	:= "0000000000"					// Numero da Declaracao de Importacao			
			D37->D37_NF		:= "0000000"	// Numero da NF					
			D37->D37_SERIE	:= "00"						// Codigo SIMP da Serie da NF
			D37->D37_DATAOP	:= cDataOp						// Data da emissao da NF
			D37->D37_SERVIC	:= "0" 							// Codigo do Servico Acordado (DUTOS)
			D37->D37_CFISQU	:= "000"		 				// Codigo da Caracteristica Fisico-Quimica do Produto
			D37->D37_METAFE	:= "000"						// Codigo do Metodo de Afericao utilizado para afericao da Car. Fis-Quim.
		//	D37->D37_UM_CFQ	:= "00"							// Codigo da Unidade de Medida da Carac. Fis-Quim. do Produto
			D37->D37_MODFRT	:= "00"	
			D37->D37_VALOR	:= "0000000000" 				// Valor da Caracteristica Fis-Quim. Expresso na un. medida acima
			D37->D37_PROOPE	:= "000000000"					// Codigo do produto quando Operacao de Transferencia ou Codigo da Operacao origem, quando operacao de devolucao
			D37->D37_MASSA	:= Right("0000000" + Alltrim(StrTran(Transform(SD3->D3_MASSA, "99999999.999"), ".", "")), 7)	// Massa especIfica expressa em kg/m3 a 1 (uma) atmosfera
			D37->D37_RECGLP	:= "00"							// ?? Codigo do Recipiente utilizado em operacoes com botijoes de GLP
			D37->D37_CHVNFE := "00000000000000000000000000000000000000000000" //Chave DANFE
			MsUnlock()
		EndIf
		
		cObs := ""
		DbSelectArea("SD3")
		DbSkip()
		IncProc("Processando Movimentação Interna. Registro: " + Str(nReg))
	Enddo
cFilAnt := cFilCtrl

Return()
      
//-------------------------------------------------------------------
/*/{Protheus.doc} ProcFim()
Gera arquivo TXT, com informacoes do i-SIMP para (ANP)
@author Itamar Oliveira
@since 01/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcFim()

Local cFilCtrl		:= cFilAnt
Local cSkpLoc		:= GetNewPar("MV_SKPLOSI", "") 
Local aQtdIni		:= {}
Local lSlTerFPro 	:=  SlTerFPro() // A função tem o encapsulamento do parametro MV_DCSTSPR porque o seu valor está como "Caractere", e no fonte é tratado como "Lógico"
Local nQtdSB9		:= 0
Local nQtdD37		:= 0
Local aOPEmT 		:= &(GetNewPar("MV_AROPEMT", "{}"))
Local lAchou		:= .F.

lFirst := .T.

	// Grava Saldo Final
	DbSelectArea("SB9")
	DbSetOrder(2)
		
	ProcRegua(RecCount())
	
	If DbSeek(cFilDe+DTOS(dDataIni-1)) //dDataFim

		nQtdSB9 := 0
		nQtdD37 := 0

		While !Eof() .And. SB9->B9_FILIAL >= cFilDe .And. SB9->B9_FILIAL <= cFilAte
			
			If SB9->B9_DATA <> dDataIni-1 //dDatafim
				DbSkip()
				Loop
			EndIf

			If SB9->B9_FILIAL <> cFilAnt .or. lFirst
				lFirst := .F.
				cFilAnt := SB9->B9_FILIAL
				cInst	:= GetNewPar("MV_INSTSIM", "")
				If Alltrim(cInst) == ""
					cObs := "Codigo da Instalação (MV_INSTSIM) não preenchido para a Filial: " + SB9->B9_FILIAL
					ErroSB9()
				EndIf
			Endif
			cSkpLoc	:= GetNewPar("MV_SKPLOSI", "")

			If !Empty(cSkpLoc) .And. SB9->B9_LOCAL$Alltrim(cSkpLoc)
				DbSkip()
				Loop
			EndIf
			
 			SB1->(DbSeek(xFilial("SB1")+SB9->B9_COD))
		    If SB1->B1_MSBLQL == "1"
    		    dbSelectArea("SB9")
       			dbSkip()
       			Loop
    		EndIf


			If Alltrim(MV_PAR05) != "" 
				If SB9->B9_COD < MV_PAR05 .Or. SB9->B9_COD > MV_PAR06
					DbSkip()
					Loop
				EndIf
			EndIf
			
			If Alltrim(MV_PAR10) != "" 			
				If SB9->B9_LOCAL < MV_PAR10 .Or. SB9->B9_LOCAL > MV_PAR11
					DbSkip()
					Loop
				EndIf
		    Endif
		    
			DH5->(DbSeek(xfilial("DH5")+SB9->B9_COD))
			If Empty(DH5->DH5_CODSIM)
				DbSelectArea("SB9")
				DbSkip()
				Loop
			EndIf
								
			If SB9->B9_QINI < 0
				cObs := "Quantidade Negativa"
				ErroSB9()
			EndIf

			DbSelectArea("D37")
			DbSetOrder(2)
			If Empty(cObs)
				If nQtdSB9 == 0 
					If D37->(DbSeek(SB9->B9_FILIAL+MV_PAR01+MV_PAR02+aOPEmT[2]+StrZero(Val(DH5->DH5_CODSIM), 9)))
						nQtdSB9:= D37->D37_QTDPRD
					EndIf
				EndIf
				nQtdSB9+= SB9->B9_QINI
				lAchou:=.F.
				If D37->(DbSeek(SB9->B9_FILIAL+MV_PAR01+MV_PAR02+aOperInt[2]+StrZero(Val(DH5->DH5_CODSIM), 9)))
					//Ja existe um registro com esses dados 
					lAchou:=.T.
					If !lSlTerFPro
						DbSelectArea("SB9")
						DbSkip()
						Loop
					EndIf
				EndIf 
				         
				if lSlTerFPro .And. lAchou
					RecLock("D37",.F.)
				Else
					RecLock("D37",.T.)
				EndIf
				D37->D37_FILIAL	:= SB9->B9_FILIAL						// Filial
				D37->D37_ARI	:= cCDSMP 								// Codigo SIMP do ARI
				D37->D37_MES	:= MV_PAR01 							// Mes
				D37->D37_ANOREF	:= MV_PAR02 							// Ano
				D37->D37_OPERAC	:= aOperInt[2] 							// Operacao
				D37->D37_INST1	:= StrZero(Val(cInst), 7)				// Instalacao 1 (armazem)
				D37->D37_INST2	:= "0000000" 							// Instalacao 2 (armazem)
				D37->D37_CODPRD	:= StrZero(Val(DH5->DH5_CODSIM), 9)  	// Codigo SIMP do Produto
                            
  				SB5->(DbSeek(xFilial("SB5")+SB9->B9_COD))
  				
  				// Tratamendo Saldo Final
  				aQtdIni := CalcFim(DH5->DH5_CODSIM)
				
				If SB5->(Fieldpos("B5_CDCL1")) <> 0 .and. SB5->B5_CDCL1 <> 0  // Fator de conversão para a primeira unidade de medida
					If SB5->B5_TCDCL1 == "M"
						D37->D37_QTDPRD := Round((aQtdIni[1] * SB5->B5_CDCL1),0)
					Else
						D37->D37_QTDPRD := Round((aQtdIni[1] / SB5->B5_CDCL1),0)
					EndIf
				Else					
					D37->D37_QTDPRD := Round((aQtdIni[1]),0)	// Qtde
				EndIf		
                                                     
                                                     
				If DH5->(Fieldpos("DH5_CONVDC")) <> 0 // Fator de conversão para a terceira unidade de medida
					If DH5->DH5_TCONDC == "M"
						D37->D37_QTDEKG	:= Round((aQtdIni[1] * DH5->DH5_CONVDC),0) 
					Else
						D37->D37_QTDEKG	:= Round((aQtdIni[1] / DH5->DH5_CONVDC),0) 
					EndIf
				Else					
					// A quantidade em KG devera ser extraida do campo de qtde da 2nd. Un. Medida
					D37->D37_QTDEKG	:= Round((IIf(aQtdIni[2] <= 0, aQtdIni[1], aQtdIni[2])),0)
				EndIf

				D37->D37_MODAL	:= "0"				// Modal
				D37->D37_VEICUL	:= "0000000"		// Veiculo (Embarcacao)
				D37->D37_TERCEI	:= "00000000000000"	// Codigo do Terceiro (Campo 12)
				D37->D37_MUNIC	:= "0000000" 		// Codigo do Municipio do Terceiro que foi identIficado no campo acima (12)
				D37->D37_ATIVEC	:= "00000" 			// Codigo da Atividade Economica do Agente economico identIficado no campo 12
				D37->D37_PAIS	:= "0000" 			// Codigo do Pais de importacao ou exportacao do produto
				D37->D37_LICIMP	:= "0000000000"		// Numero da Licenca de Importacao
				D37->D37_DECIMP	:= "0000000000"		// Numero da Declaracao de Importacao
				D37->D37_NF		:= "0000000"		// Numero da NF
				D37->D37_SERIE	:= "00"				// Codigo SIMP da Serie da NF
				D37->D37_DATAOP	:= "00000000"		// Data da emissao da NF
				D37->D37_SERVIC	:= "0" 				// Codigo do Servico Acordado (DUTOS)
				D37->D37_CFISQU	:= "000"			// Codigo da Caracteristica Fisico-Quimica do Produto
				D37->D37_METAFE	:= "000"			// Codigo do Metodo de Afericao utilizado para afericao da Car. Fis-Quim.
			//	D37->D37_UM_CFQ	:= "00"				// Codigo da Unidade de Medida da Carac. Fis-Quim. do Produto
				D37->D37_MODFRT	:= "00"	
				D37->D37_VALOR	:= "0000000000" 	// Valor da Caracteristica Fis-Quim. Expresso na un. medida acima
				D37->D37_PROOPE	:= "000000000"		// Codigo do produto quando Operacao de Transferencia ou Codigo da Operacao origem, quando operacao de devolucao
				D37->D37_MASSA	:= "0000000"		// Massa especIfica expressa em kg/m3 a 1 (uma) atmosfera
				D37->D37_RECGLP	:= "00"				// Codigo do Recipiente utilizado em operacoes com botijoes de GLP
  			    D37->D37_CHVNFE := "00000000000000000000000000000000000000000000" //Chave DANFE
  			    nQtdD37:= D37->D37_QTDPRD
				MsUnlock()				
			EndIf

			cObs	:= ""      
			DbSelectArea("SB9")
			DbSkip()
			IncProc("Processando Saldo Final")
		Enddo
		If nQtdD37 <> nQtdSB9
			cObs := "Divergencia : Saldo de Fechamento : "+cvaltochar(nQtdSB9)+" Arquivo ANP = "+cvaltochar(nQtdD37)
			ErroSb9()
		EndiF
	Else
		cObs := "Saldo atual(fechamento do mês) não localizado na data: "+DTOC(dDataFim)
		ErroSB9()
	EndIf
	
cFilAnt := cFilCtrl

Return()	

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcSB6()
Gera arquivo TXT, com informacoes do i-SIMP para (ANP)
@author Itamar Oliveira
@since 01/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcSB6()

Local aArea     := GetArea()
Local aAreaSM0  := SM0->(GetArea())
Local aOPEmT 	:= &(GetNewPar("MV_AROPEMT", "{}"))
Local aOPDeT	:= &(GetNewPar("MV_AROPDET", "{}"))      
Local aSaldo	:= {}
Local cTpCliFor	:= ""
Local cCliFor	:= ""
Local cLoja		:= ""
Local cProduto	:= ""
Local nTamCli	:= TamSx3("B6_CLIFOR")[1]
Local nTamLoja	:= TamSx3("B6_LOJA")[1]
Local nTamProd	:= TamSx3("B6_PRODUTO")[1]
Local cCodOper	:= ""
Local lCDCL1 	:= SB5->(Fieldpos("B5_CDCL1")) <> 0
Local lCONVDCL 	:= DH5->(Fieldpos("DH5_CONVDC")) <> 0
Local cInst2	:= "0000000"
Local cFilialDe := cFilDe
Local cFilialAte:= cFilAte
Local nX 		:= 1
Local nY		:= 1
Local cFilCtrl	:= cFilAnt
Local lGeraInst2  := SuperGetMV("MV_DCLINS2",.F.,.F.) 
Local lSlTerFPro  := SlTerFPro() // A função tem o encapsulamento do parametro MV_DCSTSPR porque o seu valor está como "Caractere", e no fonte é tratado como "Lógico"
Local lexist	:= .F.
Local aAreaD37	:= D37->(GetArea())

// Verifica se o arquivo é compartilhado para rodar por filial
If Empty(xFilial("D37"))
	cFilialDe := cFilAnt
	cFilialAte:= cFilAnt
EndIf
                   
dbSelectArea("SB5")
dbSelectArea("SB1")
dbSelectArea("SA1")
dbSelectArea("SA2")
dbSelectArea("SM0")   
SM0->(MsSeek(cEmpAnt+cFilialDe))

While SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmpAnt .And. SM0->M0_CODFIL >= cFilialDe .And. SM0->M0_CODFIL <= cFilialAte
      
	// Troca a Filial
	cFilAnt := FWCodFil()
	cInst	:= GetNewPar("MV_INSTSIM", "")

	For nY := 1 to 4
	
		If nY == 1    			// EM Terceiro

			// Saldo Inicial em Terceiros
			aSaldo		:= SaldoTerc(MV_PAR05,MV_PAR10,"T",dDataIni-1,MV_PAR11,.T.,MV_PAR06,.T.)
			cCodOper	:= aOPEmT[1]
		ElseIf nY == 2

			// Saldo Final em Terceiros
			aSaldo 		:= SaldoTerc(MV_PAR05,MV_PAR10,"T",dDataFim,MV_PAR11,.T.,MV_PAR06,.T.)
			cCodOper	:= aOPEmT[2]
	    ElseIf nY == 3           // DE Terceiro

			// Saldo Inicial de Terceiros
			aSaldo		:= SaldoTerc(MV_PAR05,MV_PAR10,"D",dDataIni-1,MV_PAR11,.T.,MV_PAR06,.T.)
			cCodOper	:= aOPDeT[1]
		Else

			// Saldo Final de Terceiros	
			aSaldo 		:= SaldoTerc(MV_PAR05,MV_PAR10,"D",dDataFim,MV_PAR11,.T.,MV_PAR06,.T.)	
			cCodOper	:= aOPDeT[2]
	    EndIf
		
		If  aSaldo <> Nil .And. Len(aSaldo) > 0 .And. Len(aSaldo[1]) > 3
	        
			For nX := 1 to Len(aSaldo)  // Quebra por Produto/Cli-For 
		   		
				cTpCliFor 	:= Substr(aSaldo[nX][1], 1,1)          			//C= Cliente e F = Fornecedor
				cCliFor		:= Substr(aSaldo[nX][1], 2,nTamCli)
	 			cLoja		:= Substr(aSaldo[nX][1], 2+nTamCli,nTamLoja)
				cProduto	:= Substr(aSaldo[nX][1], 2+nTamCli+nTamLoja,nTamProd)
			
			    SB1->(MsSeek(xFilial("SB1")+cProduto ))
			    
			    If !Empty(DH5->DH5_CODSIM)
			
					If cTpCliFor == "F"
						// Instalacao 2 - Fornecedor
						If D30->(DbSeek(xFilial("D30")+cCliFor+cLoja))
							SA2->(DbSeek(xFilial("SA2")+cCliFor+cLoja))
							cTerceiro 	:= StrZero(Val(SA2->A2_CGC),14)
							cMunicTer 	:= StrZero(Val(D30->D30_MUNSIM),7)
							cAtividTer 	:= StrZero(Val(D30->D30_ATVSIM),5)
    
							If lGeraInst2
								cInst2 := StrZero(Val(D30->D30_INSTSI),7)
							Else
								cInst2 := "0000000"
							EndIf
						Else
							cTerceiro 	:= "00000000000000"
							cMunicTer 	:= "0000000"
							cAtividTer 	:= "00000"
							cInst2      := "0000000"
						EndIf
						
					Else
						// Instalacao 2 - Cliente
						If AI0->(DbSeek(xFilial("AI0")+cCliFor+cLoja))
							SA1->(DbSeek(xFilial("SA1")+cCliFor+cLoja))
							cTerceiro 	:= StrZero(Val(SA1->A1_CGC),14)
							cMunicTer 	:= StrZero(Val(AI0->AI0_MUNSI),7)
							cAtividTer 	:= StrZero(Val(AI0->AI0_ATVSI),5)
 
							If lGeraInst2
							   cInst2 := StrZero(Val(AI0->AI0_CODINS),7)
							Else
								cInst2 := "0000000"
							Endif
						Else
							cInst2 := "0000000"
							cTerceiro 	:= "00000000000000"
							cMunicTer 	:= "0000000"
							cAtividTer 	:= "00000"
						EndIf
						
					EndIf

					cMassa := "0000000"
					lexist:=.F.
					aAreaD37 := D37->(GetArea ())
					D37->(DbSetOrder(5)) //D37_FILIAL+D37_ARI+D37_MES+D37_ANOREF+D37_OPERAC+D37_INST1+D37_INST2+D37_CODPRD+D37_TERCEI
					If D37->(DbSeek(cFilAnt+cCDSMP+MV_PAR01+MV_PAR02+cCodOper+StrZero(Val(cInst), 7)+StrZero(Val(cInst2), 7)+StrZero(Val(DH5->DH5_CODSIM), 9)+cTerceiro))
						RecLock("D37",.F.)
						lexist:=.T.
					else						
						RecLock("D37",.T.)
					EndIf
					D37->D37_FILIAL	:= cFilAnt 								// Filial
					D37->D37_ARI	:= cCDSMP 								// Codigo SIMP do ARI
					D37->D37_MES	:= MV_PAR01 							// Mes
					D37->D37_ANOREF	:= MV_PAR02 							// Ano
					D37->D37_OPERAC	:= cCodOper								// Operacao
					D37->D37_INST1	:= StrZero(Val(cInst), 7)				// Instalacao 1 (armazem)
					D37->D37_INST2	:= StrZero(Val(cInst2), 7)				// ?? Instalacao 2 (armazem)
					D37->D37_CODPRD	:= StrZero(Val(DH5->DH5_CODSIM), 9)  	// Codigo SIMP do Produto
					
					
					SB5->(MsSeek(xFilial("SB5")+SB1->B1_COD))
					DH5->(MsSeek(xFilial("DH5")+SB1->B1_COD))
					If lexist
						If lCDCL1  	// Fator de conversão para a primeira unidade de medida
							If SB5->B5_TCDCL1 == "M"
								D37->D37_QTDPRD +=  Round((aSaldo[nX][2] * SB5->B5_CDCL1),0)
							Else
								D37->D37_QTDPRD +=  Round((aSaldo[nX][2] / SB5->B5_CDCL1),0)
							EndIf
						Else
							D37->D37_QTDPRD += Round((aSaldo[nX][2]),0)	// Qtde
						EndIf
						
						If lCONVDCL 	// Fator de conversão para a terceira unidade de medida
							If DH5->DH5_TCONDC == "M"
								D37->D37_QTDEKG	+= Round((aSaldo[nX][2] * DH5->DH5_CONVDC),0)
							Else
								D37->D37_QTDEKG	+= Round((aSaldo[nX][2] / DH5->DH5_CONVDC),0)
							EndIf
						Else
							// A quantidade em KG devera ser extraida do campo de qtde da 2nd. Un. Medida
							D37->D37_QTDEKG	+= Round((aSaldo[nX][2]),0)
						EndIf
					Else
						If lCDCL1  	// Fator de conversão para a primeira unidade de medida
							If SB5->B5_TCDCL1 == "M"
								D37->D37_QTDPRD :=  Round((aSaldo[nX][2] * SB5->B5_CDCL1),0)
							Else
								D37->D37_QTDPRD :=  Round((aSaldo[nX][2] / SB5->B5_CDCL1),0)
							EndIf
						Else
							D37->D37_QTDPRD := Round((aSaldo[nX][2]),0)	// Qtde
						EndIf
						
						If lCONVDCL 	// Fator de conversão para a terceira unidade de medida
							If DH5->DH5_TCONDC == "M"
								D37->D37_QTDEKG	:= Round((aSaldo[nX][2] * DH5->DH5_CONVDC),0)
							Else
								D37->D37_QTDEKG	:= Round((aSaldo[nX][2] / DH5->DH5_CONVDC),0)
							EndIf
						Else
							// A quantidade em KG devera ser extraida do campo de qtde da 2nd. Un. Medida
							D37->D37_QTDEKG	:= Round((aSaldo[nX][2]),0)
						EndIf
					EndIf			
					D37->D37_MODAL	:= "0"				// Modal
					D37->D37_VEICUL	:= "0000000"		// Veiculo (Embarcacao)
					D37->D37_TERCEI	:= cTerceiro   	    // Codigo do Terceiro (Campo 12) CNPJ
					D37->D37_MUNIC	:= cMunicTer 		// Codigo do Municipio do Terceiro que foi identIficado no campo acima (12)
					D37->D37_ATIVEC	:= cAtividTer		// Codigo da Atividade Economica do Agente economico identIficado no campo 12
					D37->D37_PAIS	:= "0000" 			// Codigo do Pais de importacao ou exportacao do produto
					D37->D37_LICIMP	:= "0000000000"		// Numero da Licenca de Importacao
					D37->D37_DECIMP	:= "0000000000"		// Numero da Declaracao de Importacao
					D37->D37_NF		:= "0000000"		// Numero da NF
					D37->D37_SERIE	:= "00"				// Codigo SIMP da Serie da NF
					D37->D37_DATAOP	:= "00000000"		// Data da emissao da NF
					D37->D37_SERVIC	:= "0" 				// Codigo do Servico Acordado (DUTOS)
					D37->D37_CFISQU	:= "000"		 	// Codigo da Caracteristica Fisico-Quimica do Produto
					D37->D37_METAFE	:= "000"			// Codigo do Metodo de Afericao utilizado para afericao da Car. Fis-Quim.
				//	D37->D37_UNMCFQ	:= "00"				// Codigo da Unidade de Medida da Carac. Fis-Quim. do Produto
					D37->D37_MODFRT	:= "00"					
					D37->D37_VALOR	:= "0000000000" 	// Valor da Caracteristica Fis-Quim. Expresso na un. medida acima
					D37->D37_PROOPE	:= "000000000"		// Codigo do produto quando Operacao de Transferencia ou Codigo da Operacao origem, quando operacao de devolucao
					D37->D37_MASSA	:= cMassa			// Massa espeficia do produto expressa em kg/m3 a 1 (uma) atmosfera
					D37->D37_RECGLP	:= "00"				// Codigo do Recipiente utilizado em operacoes com botijoes de GLP
					D37->D37_CHVNFE := "00000000000000000000000000000000000000000000" //Chave DANFE
					MsUnlock() 
					
					D37->(DbSetOrder(2))
					If lSlTerFPro
						If nY == 1
							nQTdeSP   := D37->D37_QTDPRD          // armazena saldo inicial terceiros para agregar no saldo inicial proprio. 
							nQtdeKgSP := D37->D37_QTDEKG
							If D37->(DbSeek(D37->D37_FILIAL+MV_PAR01+MV_PAR02+aOperInt[1]+StrZero(Val(DH5->DH5_CODSIM), 9)))							
								RecLock("D37",.F.)
								D37->D37_QTDPRD   += nQTdeSP
								D37->D37_QTDEKG	+= nQtdeKgSP
								MsUnlock()
							EndIf
						EndIf					 
						If nY == 2
							nQTdeSP   := D37->D37_QTDPRD          // armazena saldo final terceiros para agregar no saldo final proprio. 
							nQtdeKgSP := D37->D37_QTDEKG
							If D37->(DbSeek(D37->D37_FILIAL+MV_PAR01+MV_PAR02+aOperInt[2]+StrZero(Val(DH5->DH5_CODSIM), 9)))
								RecLock("D37",.F.)
								D37->D37_QTDPRD   += nQTdeSP
								D37->D37_QTDEKG	+= nQtdeKgSP
							Else
								RecLock("D37",.T.)
								D37->D37_FILIAL	:= cFilAnt 								// Filial
								D37->D37_ARI	:= cCDSMP 										// Codigo SIMP do ARI
								D37->D37_MES	:= MV_PAR01 									// Mes
								D37->D37_ANOREF	:= MV_PAR02 									// Ano
								D37->D37_CODPRD	:= StrZero(Val(DH5->DH5_CODSIM), 9)  	// Codigo SIMP do Produto
								D37->D37_OPERAC	:= aOperInt[2] 							// Operacao								
								D37->D37_QTDPRD   	+= nQTdeSP
								D37->D37_QTDEKG	+= nQtdeKgSP		
								D37->D37_INST1	:= StrZero(Val(cInst), 7)				// Instalacao 1 (armazem)
								D37->D37_INST2	:= "0000000"			// ?? Instalacao 2 (armazem)
								D37->D37_MODAL	:= "0"				// Modal
								D37->D37_VEICUL	:= "0000000"		// Veiculo (Embarcacao)
								D37->D37_TERCEI	:= "00000000000000"   	    // Codigo do Terceiro (Campo 12) CNPJ
								D37->D37_MUNIC	:= "0000000" 		// Codigo do Municipio do Terceiro que foi identIficado no campo acima (12)
								D37->D37_ATIVEC	:= "00000"		// Codigo da Atividade Economica do Agente economico identIficado no campo 12
								D37->D37_PAIS	:= "0000" 			// Codigo do Pais de importacao ou exportacao do produto
								D37->D37_LICIMP		:= "0000000000"		// Numero da Licenca de Importacao
								D37->D37_DECIMP		:= "0000000000"		// Numero da Declaracao de Importacao
								D37->D37_NF		:= "0000000"		// Numero da NF
								D37->D37_SERIE	:= "00"				// Codigo SIMP da Serie da NF
								D37->D37_DATAOP	:= "00000000"		// Data da emissao da NF
								D37->D37_SERVIC	:= "0" 				// Codigo do Servico Acordado (DUTOS)
								D37->D37_CFISQU	:= "000"		 	// Codigo da Caracteristica Fisico-Quimica do Produto
								D37->D37_METAFE	:= "000"			// Codigo do Metodo de Afericao utilizado para afericao da Car. Fis-Quim.
							//	D37->D37_UNMCFQ	:= "00"				// Codigo da Unidade de Medida da Carac. Fis-Quim. do Produto
								D37->D37_MODFRT	:= "00"	
								D37->D37_VALOR	:= "0000000000" 	// Valor da Caracteristica Fis-Quim. Expresso na un. medida acima
								D37->D37_PROOPE	:= "000000000"		// Codigo do produto quando Operacao de Transferencia ou Codigo da Operacao origem, quando operacao de devolucao
								D37->D37_MASSA	:= cMassa			// Massa espeficia do produto expressa em kg/m3 a 1 (uma) atmosfera
								D37->D37_RECGLP	:= "00"				// Codigo do Recipiente utilizado em operacoes com botijoes de GLP
								D37->D37_CHVNFE := "00000000000000000000000000000000000000000000" //Chave DANFE
							EndIf		
							MsUnlock()				
						EndIf
					EndIf	
					RestArea(aAreaD37)
              EndIf
			Next nX
	    EndIf
	Next nY
	IncProc("Processando Saldo em/de Poder de Terceiros")
	SM0->(DbSkip())
EndDo

RestArea(aAreaSM0)
cFilAnt := FWCodFil()
RestArea(aArea)

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcTot()
Gera arquivo TXT, com informacoes do i-SIMP para (ANP)
@author Itamar Oliveira
@since 01/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcTot()

Local aArea     := GetArea()
Local aAreaSM0  := SM0->(GetArea())
Local aSubTot   := {}
Local aTotal    := {}
Local cIdent    := ""
Local nPosicao 	:= 0
Local cFilialDe := cFilDe
Local cFilialAte:= cFilAte

// Verifica se o arquivo é compartilhado para rodar por filial
If Empty(xFilial("D37"))
	cFilialDe := cFilAnt
	cFilialAte:= cFilAnt
EndIf

dbSelectArea("SM0")
MsSeek(cEmpAnt+cFilialDe)
While !Eof() .And. SM0->M0_CODIGO == cEmpAnt .And.;
					SM0->M0_CODFIL >= cFilialDe .And.;
					SM0->M0_CODFIL <= cFilialAte 

 	// Troca a Filial
	cFilAnt := SM0->M0_CODFIL
	cInst	:= GetNewPar("MV_INSTSIM", "")
	cIdent  := ""
	aSubTot := {}
	aTotal  := {}
		
	// Calcular totalizadores por operacao 	
	DbSelectArea("D37")
	DbSetOrder(2)
	D37->(DbSeek(xFilial("D37")+MV_PAR01+MV_PAR02))
	While !Eof() .And. D37->D37_FILIAL == xFilial("D37") .And.;
		D37->D37_MES == MV_PAR01 .And.;
		D37->D37_ANOREF == MV_PAR02
		
		If (Empty(cIdent) .Or. Empty(D37->D37_IDENT) .Or. cIdent <> D37->D37_IDENT) .And. SubStr(D37->D37_OPERAC,5,3) <> "998"
		
			// Verifica se existe a operacao totalizadora cadastrada
			DbSelectArea("D3C")
			DbSetOrder(2)
			If D3C->(DbSeek(xFilial("D3C")+Left(D37->D37_OPERAC,4)+"998"))
				nPosicao := aScan(aSubTot,{|x| x[1] == D37->D37_CODPRD .And. x[2] == Left(D37->D37_OPERAC,4) })
				If nPosicao == 0
					aadd(aSubTot,{D37->D37_CODPRD,;
									Left(D37->D37_OPERAC,4),;
									0,;
									0,;
									"0"})
					nPosicao := Len(aSubTot)
				EndIf
				aSubTot[nPosicao][3] += D37->D37_QTDPRD
				aSubTot[nPosicao][4] += D37->D37_QTDEKG
				aSubTot[nPosicao][5] := StrZero(Val(aSubTot[nPosicao][5]) + Val(D37->D37_MASSA),7)
	
				nPosicao := aScan(aTotal,{|x| x[1] == D3C->D3C_CLASSE .And. x[2] == D37->D37_CODPRD })
				If nPosicao == 0
					aadd(aTotal,{ D3C->D3C_CLASSE,;
									D37->D37_CODPRD,;
									0,;
									0,;
									"0"})
					nPosicao := Len(aTotal)
				EndIf
				aTotal[nPosicao][3] += D37->D37_QTDPRD
				aTotal[nPosicao][4] += D37->D37_QTDEKG
				aTotal[nPosicao][5] := StrZero(Val(aTotal[nPosicao][5]) + Val(D37->D37_MASSA),7)
			EndIf
		EndIf
		
		cIdent := D37->D37_IDENT
			
		DbSelectArea('D37')
		DbSkip()  
	EndDo
		
	For nPosicao := 1 To Len(aSubTot)
		RecLock("D37",.T.)
		D37->D37_FILIAL	:= xFilial("D37")
		D37->D37_ARI	:= cCDSMP 					// Codigo SIMP do ARI
		D37->D37_MES	:= MV_PAR01 				// Mes
		D37->D37_ANOREF	:= MV_PAR02 				// Ano
		D37->D37_OPERAC	:= aSubTot[nPosicao][2] + "998"
		D37->D37_INST1	:= cInst					// Instalacao 1 (armazem)
		D37->D37_INST2	:= "0000000"				// Instalacao 2 (armazem)
		D37->D37_CODPRD	:= aSubTot[nPosicao][1]		// Codigo SIMP do Produto
		D37->D37_QTDPRD	:= aSubTot[nPosicao][3]		// Qtde
		D37->D37_QTDEKG	:= aSubTot[nPosicao][4]		// Qtde em KM - Fazer funcao para converter UM
		D37->D37_MODAL	:= "0"						// Modal
		D37->D37_VEICUL	:= "0000000"				// Veiculo (Embarcacao)
		D37->D37_TERCEI	:= "00000000000000"			// Codigo do Terceiro (Campo 12)
		D37->D37_MUNIC	:= "0000000" 				// Codigo do Municipio do Terceiro que foi identIficado no campo acima (12)
		D37->D37_ATIVEC	:= "00000" 					// Codigo da Atividade Economica do Agente economico identIficado no campo 12
		D37->D37_PAIS	:= "0000" 					// Codigo do Pais de importacao ou exportacao do produto
		D37->D37_LICIMP	:= "0000000000"				// Numero da Licenca de Importacao
		D37->D37_DECIMP		:= "0000000000"				// Numero da Declaracao de Importacao
		D37->D37_NF		:= "0000000"				// Numero da NF
		D37->D37_SERIE	:= "00"						// Codigo SIMP da Serie da NF
		D37->D37_DATAOP	:= "00000000"				// Data da emissao da NF
		D37->D37_SERVIC	:= "0" 						// Codigo do Servico Acordado (DUTOS)
		D37->D37_CFISQU	:= "000"		 			// Codigo da Caracteristica Fisico-Quimica do Produto
		D37->D37_METAFE	:= "000"					// Codigo do Metodo de Afericao utilizado para afericao da Car. Fis-Quim.
	//	D37->D37_UM_CFQ	:= "00"						// Codigo da Unidade de Medida da Carac. Fis-Quim. do Produto
		D37->D37_MODFRT	:= "00"	
		D37->D37_VALOR	:= "0000000000" 			// Valor da Caracteristica Fis-Quim. Expresso na un. medida acima
		D37->D37_PROOPE	:= "000000000"				// Codigo do produto quando Operacao de Transferencia ou Codigo da Operacao origem, quando operacao de devolucao

        D37->D37_MASSA  := "0000000"
		D37->D37_RECGLP	:= "00"						// Codigo do Recipiente utilizado em operacoes com botijoes de GLP
		D37->D37_CHVNFE := "00000000000000000000000000000000000000000000" //Chave DANFE
		MsUnlock()
	Next nPosicao

	For nPosicao := 1 To Len(aTotal)
		RecLock("D37",.T.)
		D37->D37_FILIAL	:= xFilial("D37")
		D37->D37_ARI	:= cCDSMP 					// Codigo SIMP do ARI
		D37->D37_MES	:= MV_PAR01 				// Mes
		D37->D37_ANOREF	:= MV_PAR02 				// Ano
		D37->D37_OPERAC	:= IIF(aTotal[nPosicao][1]=="1",GetMv("MV_OPMVENT"),GetMv("MV_OPMVSAI"))
		D37->D37_INST1	:= cInst					// Instalacao 1 (armazem)
		D37->D37_INST2	:= "0000000"				// Instalacao 2 (armazem)
		D37->D37_CODPRD	:= aTotal[nPosicao][2]		// Codigo SIMP do Produto
		D37->D37_QTDPRD	:= aTotal[nPosicao][3]		// Qtde
		D37->D37_QTDEKG	:= aTotal[nPosicao][4]		// Qtde em KM - Fazer funcao para converter UM
		D37->D37_MODAL	:= "0"						// Modal
		D37->D37_VEICUL	:= "0000000"				// Veiculo (Embarcacao)
		D37->D37_TERCEI	:= "00000000000000"			// Codigo do Terceiro (Campo 12)
		D37->D37_MUNIC	:= "0000000" 				// Codigo do Municipio do Terceiro que foi identIficado no campo acima (12)
		D37->D37_ATIVEC	:= "00000" 					// Codigo da Atividade Economica do Agente economico identIficado no campo 12
		D37->D37_PAIS	:= "0000" 					// Codigo do Pais de importacao ou exportacao do produto
		D37->D37_LICIMP	:= "0000000000"				// Numero da Licenca de Importacao
		D37->D37_DECIMP		:= "0000000000"				// Numero da Declaracao de Importacao
		D37->D37_NF		:= "0000000"				// Numero da NF
		D37->D37_SERIE	:= "00"						// Codigo SIMP da Serie da NF
		D37->D37_DATAOP	:= "00000000"				// Data da emissao da NF
		D37->D37_SERVIC	:= "0" 						// Codigo do Servico Acordado (DUTOS)
		D37->D37_CFISQU	:= "000"		 			// Codigo da Caracteristica Fisico-Quimica do Produto
		D37->D37_METAFE	:= "000"					// Codigo do Metodo de Afericao utilizado para afericao da Car. Fis-Quim.
	//  D37->D37_UMCFQ	:= "00"						// Codigo da Unidade de Medida da Carac. Fis-Quim. do Produto
		D37->D37_MODFRT	:= "00"	
		D37->D37_VALOR	:= "0000000000" 			// Valor da Caracteristica Fis-Quim. Expresso na un. medida acima
		D37->D37_PROOPE	:= "000000000"				// Codigo do produto quando Operacao de Transferencia ou Codigo da Operacao origem, quando operacao de devolucao

        D37->D37_MASSA  := "0000000"
		D37->D37_RECGLP	:= "00"						// Codigo do Recipiente utilizado em operacoes com botijoes de GLP
    	D37->D37_CHVNFE := "00000000000000000000000000000000000000000000" //Chave DANFE
		MsUnlock()
	Next nPosicao	
	
	DbSelectArea('SM0')
	DbSkip() 
EndDo
RestArea(aAreaSM0)
cFilAnt := SM0->M0_CODFIL
RestArea(aArea)

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} RptDetail()
Imprime relatorio com informacoes do i-SIMP para (ANP)
@author Itamar Oliveira
@since 01/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RptDetail(oTempTMP,oTempTCO)

If MV_PAR04 == 1
	Cabec1:= "Documento               Data         Doc    Serie   Oper.SIMP  Cod.Prod.          Obs."
//	Cabec1:= "Documento               Data         Doc    Serie   Oper.SIMP  Tipo Cli/For  Tipo Cod.Orig/Dest    Orig/Dest  Cod.Ativ.  Cod.Prod.          Obs."
			//Documento               Data         Doc    Serie   Oper.SMP  Tp.Cli. Orig/Dest  Cod.Ativ.  Cod.Prod.       Obs."
	Cabec2:=""
	DbSelectArea("TMPDCL")
	DbGoTop()
	li:=60
	SetRegua(RecCount())
	While ! Eof()
		IncRegua()
		If li > 55
			li :=1
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
			LI:=li+1
		EndIf
		@ LI,00 psay Substr(TMPDCL->TIPO,1,20)
		@ LI,23 psay DTOC(TMPDCL->DATA1)
		@ LI,36 psay TMPDCL->DOC
		@ LI,45 psay TMPDCL->SERIE
		@ LI,54 psay TMPDCL->OPERAC
		@ LI,63 psay TMPDCL->COD
		@ LI,77 psay TMPDCL->OBS
		//Documento               Data         Doc    Serie   Oper.SMP  Tipo Cli/For  Tipo Cod.Orig/Dest    Orig/Dest  Cod.Ativ.  Cod.Prod.       Obs."
		//XXXXXXXXXXXXXXXXXXXX  99/99/99     XXXXXX   XXX      9999     XXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXX   XXXXXXX      XXXX    XXXXXXXXXXXXXXX  X
		//                      23            36       45       54      63            77                      101          114     122              139
		LI:=LI+1
		DbSkip()
	Enddo
	Roda(0," ",Tamanho)
	Set device to Screen
	If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
		Set Printer to
		Commit
		Ourspool(wnrel)
	EndIf
	Ms_Flush()
EndIf

oTempTMP:Delete()
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ErroSB9()
Erro da tabela SB9 - Saldos Inicial e/ou Final
@author Itamar Oliveira
@since 01/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ErroSB9()

DbSelectArea("TMPDCL")
RecLock("TMPDCL",.T.)
TMPDCL->TIPO    	:= "SALDO INICIAL/FINAL"
If ! Eof()
	TMPDCL->DATA1  := SB9->B9_DATA
	TMPDCL->COD    := SB9->B9_COD
EndIf
TMPDCL->OBS     	:= cObs
MsUnlock()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ErroSD1()
Erro da tabela SD1 - Nota Fiscal de Entrada
@author Itamar Oliveira
@since 01/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ErroSD1()

DbSelectArea("TMPDCL")
RecLock("TMPDCL",.T.)
TMPDCL->TIPO    := "NOTA DE ENTRADA"
TMPDCL->DATA1   := SD1->D1_DTDIGIT
TMPDCL->COD     := SD1->D1_COD
TMPDCL->DOC     := SD1->D1_DOC
TMPDCL->SERIE   := SD1->D1_SERIE
TMPDCL->OPERAC  := SF4->F4_COPSIMP
TMPDCL->OBS     := cObs
MsUnlock()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ErroSD2()
Erro da tabela SD2 - Nota Fiscal de Entrada
@author Itamar Oliveira
@since 01/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ErroSD2()

DbSelectArea("TMPDCL")
RecLock("TMPDCL",.T.)
TMPDCL->TIPO    := "NOTA DE SAIDA"
TMPDCL->DATA1   := SD2->D2_EMISSAO
TMPDCL->COD     := SD2->D2_COD
TMPDCL->DOC     := SD2->D2_DOC
TMPDCL->SERIE   := SD2->D2_SERIE
TMPDCL->OPERAC  := SF4->F4_COPSIMP
TMPDCL->OBS     := cObs
MsUnlock()

Return               

//-------------------------------------------------------------------
/*/{Protheus.doc} ErroSD3()
Erro da tabela SD3 - Nota Fiscal de Entrada
@author Itamar Oliveira
@since 01/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ErroSD3()

DBSelectArea("TMPDCL")
RecLock("TMPDCL",.T.)
TMPDCL->TIPO    :=	" MOVIMENTO INTERNO "
TMPDCL->DATA1   := SD3->D3_EMISSAO
TMPDCL->COD     := SD3->D3_COD
TMPDCL->OPERAC  := SF5->F5_COPSIMP
TMPDCL->OBS     := cObs
MsUnlock()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaSIMP()
Validacao das obrigatoriedades do SIMP
@author Itamar Oliveira
@since 01/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------
Function ValidaSIMP()

Local lValida 	:= .T.
Local cMensagem := ""
Local cCodSimp	:= GetMv("MV_CSIMPAR")
Local cOpEnt	:= GetMv("MV_OPMVENT") 
Local cOpSai	:= GetMv("MV_OPMVSAI")    
Local cOpAcS	:= GetMv("MV_ACSOBRA")
Local cOpAcP	:= GetMv("MV_ACPERDA")
Local aOPEmT 	:= &(GetNewPar("MV_AROPEMT", "{}"))
Local aOPDeT	:= &(GetNewPar("MV_AROPDET", "{}"))      

DbSelectArea("SX5")
SX5->(DbSetOrder(1)) //Tabela + Chave

If SX5->(DbSeek(xFilial()+"HJ"+"SB9ISI"))    
	AADD(aOperInt, Substr(SX5->(X5DESCRI()), 1, 7))
EndIf

If SX5->(DbSeek(xFilial()+"HJ"+"SB9ISF"))          
	AADD(aOperInt, Substr(SX5->(X5DESCRI()), 1, 7))
EndIf
    
If SX5->(DbSeek(xFilial()+"HJ"+"SB6ETS"))   
	AADD(aOperInt, Substr(SX5->(X5DESCRI()), 1, 7))
EndIf

If SX5->(DbSeek(xFilial()+"HJ"+"SB6DTS"))   
	AADD(aOperInt, Substr(SX5->(X5DESCRI()), 1, 7))
EndIf
	
If lValida
	cMensagem := "É necessario o preenchimento do codigo de operacoes na Tabela "
	cMensagem += "IB (SX5) para as seguIntes operacoes: "

	If Alltrim(aOperInt[1]) == ""
		cMensagem += "Saldos Iniciais (SB9ISI)"
		lValida := .F.
	EndIf
	
	If Alltrim(aOperInt[2]) == ""                        
		If Right(cMensagem, 1) == ")"
			cMensagem += ", Saldos Finais (SB9ISF)"
		Else
			cMensagem += "Saldos Finais (SB9ISF)"
		EndIf
		lValida := .F.
	EndIf
	
	If Alltrim(aOperInt[3]) == ""
		If Right(cMensagem, 1) == ")"
			cMensagem += ", Estoque em Terceiros (SB6ETS)"
		Else
			cMensagem += "Estoque em Terceiros (SB6ETS)"
		EndIf
		lValida := .F.
	EndIf
	
	If Alltrim(aOperInt[4]) == ""      
		If Right(cMensagem, 1) == ")"
			cMensagem += ", Estoque de Terceiros (SB6DTS)"
		Else
			cMensagem += "Estoque de Terceiros (SB6DTS)"
		EndIf
		lValida := .F.
	EndIf

	If lValida == .F.
		Alert(cMensagem)
	EndIf
EndIf

If 	Alltrim(cCodSimp) == "" .Or. Alltrim(cOpEnt) == "" .Or. Alltrim(cOpSai) == "" .Or.;
	Alltrim(cOpAcS) == "" .Or. Alltrim(cOpAcP) == "" .Or. Len(aOPEmT) == 0 .Or. Len(aOPDeT) == 0
	cMensagem := "Os seguintes parametros devem estar corretamente preenchidos: "
	cMensagem += "MV_OPMVENT (Operacao SIMP totalizadora de entrada), "
	cMensagem += "MV_OPMVSAI (Operacao SIMP totalizadora de saida), "
	cMensagem += "MV_CSIMPAR (Codigo SIMP do ARI), "
	cMensagem += "MV_ACSOBRA (Operacao SIMP Sobras), "
	cMensagem += "MV_ACPERDA (Operacao SIMP Perdas), "
	cMensagem += "MV_AROPEMT (Operacao SIMP de produtos Em terceiros (Inicial e Final)), "
	cMensagem += "MV_AROPDET (Operacao SIMP de produtos De terceiros (Inicial e Final))"			
	
	Alert(cMensagem)
	lValida:=.F.
EndIf

Return lValida

//-------------------------------------------------------------------
/*/{Protheus.doc} CalcFim()
Calcula saldo final para o produto
@author Materiais
@since 01/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CalcFim(cProduto)

Local aAreaD37	:= D37->(GetArea())
Local cOpTTEnt	:= GetMv("MV_OPMVENT")
Local cOpTTSai	:= GetMv("MV_OPMVSAI")
Local nQtFim	:= 0
Local nQtFim2UM	:= 0

//"D37_FILIAL+D37_MES+D37_ANOREF+D37_OPERAC+D37_CODPRD"
DbSelectArea("D37")
DbSetOrder(2)

// Saldo Inicial
If D37->(DbSeek(SB9->B9_FILIAL+MV_PAR01+MV_PAR02+aOperInt[1]+StrZero(val(cProduto), 9)))
	nQtFim		+= D37->D37_QTDPRD
	nQtFim2UM	+= D37->D37_QTDEKG
EndIf

// Total de Entradas
If D37->(DbSeek(SB9->B9_FILIAL+MV_PAR01+MV_PAR02+cOpTTEnt+StrZero(val(cProduto), 9)))
	nQtFim		+= D37->D37_QTDPRD
	nQtFim2UM	+= D37->D37_QTDEKG
EndIf

// Total de Saidas
If D37->(DbSeek(SB9->B9_FILIAL+MV_PAR01+MV_PAR02+cOpTTSai+StrZero(val(cProduto), 9)))
	nQtFim		-= D37->D37_QTDPRD
	nQtFim2UM	-= D37->D37_QTDEKG
EndIf

RestArea(aAreaD37)

Return {nQtFim,nQtFim2UM}
//-------------------------------------------------------------------
/*/{Protheus.doc} SimpFrete
Recebe o tipo de frete dos campos F1_TPFRETE e F2_TPFRETE
e retorna conforme conforme ISIMP

10 - Por conta do emitente (CIF) 
11 - Por conta do destinatário/remetente (FOB)
12 - Por conta de terceiros 
19 - Sem frete.

@author Alexandre Gimenez 
@since 30/03/2017
@version 12.1.7 /*/
//-------------------------------------------------------------------
Static Function SimpFrete(cTipo)
Local cRet := "" 

Do Case
	Case cTipo == "C" // CIF
		cRet := "10"	
	Case cTipo == "F" // FOB
		cRet := "11"	
	Case cTipo == "T" //Terceiros
		cRet := "12"
	Case cTipo == "S" //Sem Frete
		cRet := "19"
	OtherWise 
		cRet := "00"	
End Case

Return cRet



/*/{Protheus.doc} SlTerFPro
// Foi Necessário o encapsulamento  do parametro MV_DCSTSPR porque o seu valor está como "Caractere"
// e no fonte o tratamento é validado como valor "Lógico"
// Foi solicitado o ajuste do MV_DCSTSPR, que está previsto para a próxima Release 12.1.25
@author silva.douglas
@since 08/02/2019
@version 1.0
@return ${Logico}, ${Habilta agregar sld Terc no sld inicial/final}

@type function
/*/
Static Function SlTerFPro()

Local lSlTer	 := .F.
Local uSlTerFPro := SuperGetMV("MV_DCSTSPR",.F.,.F.)

If VALTYPE(uSlTerFPro) == "C" 

	If uSlTerFPro == ".T."
		lSlTer := .T.	
	else
		lSlTer := .F.
	endif
	
Elseif VALTYPE(uSlTerFPro) == "L" 

	lSlTer := uSlTerFPro
	
Endif

Return lSlTer

/*/{Protheus.doc} cGlpObrig
	Determina se o preenchimento do Código de Vasilhame é obrigatório dado o código de Operação utilizado.
	@type  Function
	@author SQUAD Entradas
	@since 2019
	@version 1.0
	@param cOpr, character, Código de Operação utilizado
	@return lObrig, logical, se .T. então o preenchimento do código de vasilhame é obrigatório
/*/
Function CGlpObrig(cOpr)

	// Operações em que são obrigatórias o preenchimento do código de vasilhame
	Local aOprObrig := { "1012016", "1012001", "1012002", ;
	"4020001", "4020011", "4020012", "4020013" }

	Local nPos := aScan(aOprObrig, AllTrim(cOpr))
	Local lObrig := If(nPos > 0, .T., .F.)

Return lObrig
