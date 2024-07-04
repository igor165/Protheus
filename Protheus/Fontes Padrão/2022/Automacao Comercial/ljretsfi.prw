#INCLUDE "PROTHEUS.CH"
#INCLUDE "LJRETSFI.CH"

Function LJRETSFI()  ; Return   // "dummy" function - Internal Use
                                        	
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LJCRetSFI		 ºAutor  ³Vendas Clientes     º Data ³ 04.08.09 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Classe responsavel em retornar os dados da SFI                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja\FrontLoja                                           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/     
Class LJCRetSFI

	Data aRedZRet	   								//Array para armazenar o objeto oRedZRet
	
	Method New()  					                //Metodo Construtor 
	Method BuscaDados(dDataIni, dDataFim, cPDV, lHomolPAF)    //Retorna os dados da SFI

EndClass   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³New       ³ Autor ³ Venda Clientes        ³ Data ³ 04.05.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Metodo contrutor da classe LJCRetSFI						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Method New() Class LJCRetSFI
	::aRedZRet := {}

Return  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Metodo	 ³BuscaDados³ Autor ³ Venda Clientes        ³ Data ³ 04.05.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna os dados da SFI									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Method BuscaDados(dDataIni, dDataFim, cPDV, lHomolPAF) Class LJCRetSFI
Local bWhile	:= Nil
Local lVerSIG031430 := LjDLLVer(.F.,.F.) >= "0.3.143.0" //deve validar a versão da SIGALOJA (versao "0.3.143.0" ou superior) que separou os valores de ISS do ICMS	
Local cIndex	:= ""
Local cChave	:= ""
Local cCond		:= ""               
Local nCont     := 1
Local nPosImp	:= 0
Local aAux      := {} 
Local oRedZRet  := LJCSFIDados():New()   
Local oImpsSFI  := LJCFIImps():New()
Local nTotOpNFis:= 0 													//totaliza operação não fiscal                   
Local lUsaPafMdz:= AliasInDic( "MDZ" )	//sinaliza se utiliza PAF-ECF e se possui a tabela de movimento do ECF(MDZ)
Local aArea		:= {}
Local aAreaSX3	:= {}

Default lHomolPAF := .F.

cPDV := AllTrim(cPDV)
DbSelectArea("SFI")
cIndex	:= CriaTrab(Nil,.F.)
cChave	:= "FI_FILIAL+DTOS(FI_DTREDZ)"
cCond	:= "FI_FILIAL= '"+xFilial("SFI")+"' .AND. Trim(SFI->FI_PDV)='" + cPDV + "'" 
IndRegua("SFI",cIndex,cChave,,cCond,STR0001) //"Selecionando Registros..."

//deve pegar a database pois o FI_DTREDZ guarda a data do dia da redução, que é hoje,
// e o parâmetro passado contém a data do movimento que pode ser menor e com isso nao gera o R02 e R03
SFI->(DbSeek(xFilial("SFI")+DtoS(dDataBase),.T.)) 
bWhile	:= {||SFI->FI_DTREDZ == dDataBase}

//************************************************************************************************/
// 								NOTA SOBRE O CONTEUDO DAS INFORMAÇÕES DA SFI
//
// 1 -	o campo FI_CANCEL é preenchido de acordo com o modelo do ECF, existem ECFs que mandam 
//		somente os valores de cancelamento de ICMS mas outras somam ICMS + ISS
// 2 - o campo FI_DESC também depende do modelo, alguns modelos mandam desconto de ICMS 
//		e outras mandam desconto de ISS + ICMS
//-> Portanto se no processo de homologação houver alguma diferença nos valores acumulados, 
//utilizar FI_CANCEL-FI_CANISS e FI_DESC-FI_DESISS
//
//-> os campos FI_DESISS e FI_CANISS sao criados pelo UPDLOJ72 e utilizados para o sistema em geral
//************************************************************************************************/
DbSelectArea("MDZ")
MDZ->( DbSetOrder(1) )
		
While !SFI->(Eof()) .AND. Eval(bWhile)
	
	If AllTrim(SFI->FI_PDV) == cPDV
	
		oRedZRet:nContRedZ 	 	:= Val(SFI->FI_NUMREDZ)
		oRedZRet:nContOrdOp	 	:= Val(SFI->FI_COO)
		oRedZRet:nContReinic	:= Val(SFI->FI_CRO)
		oRedZRet:dDataMovto	 	:= SFI->FI_DTMOVTO
		
		If lVerSIG031430
			oRedZRet:nTotBrutDia 	:= SFI->(FI_VALCON+FI_DESC+FI_CANCEL+FI_ISS+FI_DESISS+FI_CANISS)
		Else		
			oRedZRet:nTotBrutDia 	:= SFI->(FI_VALCON+FI_DESC+FI_CANCEL+FI_ISS)
		EndIf
		
		oRedZRet:dDataRedZ	 	:= SFI->FI_DTREDZ
		oRedZRet:cHoraRedZ	 	:= SFI->FI_HRREDZ
		oRedZRet:nTotCancDia 	:= SFI->FI_CANCEL
		oRedZRet:cSerie			:= AllTrim(SFI->FI_SERPDV)
		oRedZRet:nTotCanIss		:= SFI->FI_CANISS
		
		nTotOpNFis := 0
		                            
		//Totaliza Op.Nao Fiscal 			
		MDZ->(DbSeek(xFilial("MDZ")+DtoS(SFI->FI_DTMOVTO)))	
		While (!MDZ->( EOF() ) ) .AND. MDZ->MDZ_DATA == SFI->FI_DTMOVTO
			If (MDZ->MDZ_SIMBOL == "CN") .And. (AllTrim(MDZ->MDZ_PDV) == Alltrim(SFI->FI_PDV))
				nTotOpNFis += MDZ->MDZ_VALOR	
			EndIf
			
			MDZ->(DbSkip())
		End
	
		oRedZRet:nTotOpNFis := nTotOpNFis
		
		/*Carrega Aliquotas e Valores de Impostos*/
		If !AliasInDic('CF5') //Se essa tabela não existir, dá erro na geração, por isso alerto somente
			If STFIsPOS()
				STFMessage("BuscaDados1", "ALERT", "Necessária aplicação do UPDFIS87")//""
				STFShowMessage("BuscaDados1")
			Else
				MsgAlert("Necessária aplicação do UPDFIS87")
			EndIf
			aAux := {}
		Else			
			aAux := aClone( TotalizSFI(SFI->(Recno()), .T.) )
		EndIf
		
		If Len(aAux) > 0
			nPosImp := 0
			
			For nCont := 1 To Len(aAux)
				If !(Upper(aAux[nCont][1]) $ Upper("Can-T|Can-S"))
				    Aadd( oRedZRet:aImpsSFI , {"",""} )
				    nPosImp := Len(oRedZRet:aImpsSFI)
				    oRedZRet:AIMPSSFI[nPosImp][1] := aAux[nCont][1]
				    oRedZRet:AIMPSSFI[nPosImp][2] := aAux[nCont][2]
				EndIf
			Next nCont
		EndIf
		
		AADD( ::aRedZRet, oRedZRet )
	EndIf
	SFI->(DbSkip())
End

If !Empty(cIndex)
	SFI->(DBCloseArea())
	Ferase(cIndex+OrdBagExt())
	DbSelectArea("SFI")
	SFI->(DbSetOrder(1))
EndIf	

Return .T.

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CLASSE LJCSFIDADOS CONTEM OS DADOS RETORNADOS PELA BUSCA.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJCSFIDADOS	 ºAutor  ³Vendas Clientes     º Data ³ 04.08.09 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Classe responsavel em retornar os dados da SFI                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja\FrontLoja                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/     
Class LJCSFIDados     
	
	Data nContRedZ	                   //Contador de ReducaoZ
	Data nContOrdOp	                   //Contador de Ordem de Operacao
	Data nContReinic	               //Contador de Reinicio de Operacao
	Data dDataMovto	                   //Data do Movimento
	Data dDataRedZ	                   //Data da ReducaoZ
	Data cHoraRedZ	                   //Hora da ReducaoZ
	Data nTotBrutDia	               //Total de Vendas Bruto
	Data nTotCancDia	               //Total de Cancelamento
	Data nTotOpNFis					   //Total de Op.Nao Fiscal
	Data nTotCanIss						//Valor de venda cancelada de ISS	
	Data aImpsSFI                      //Array do tipo LJCFIImps 
	Data cSerie							//Serie
	
	Method New()                       //Metodo Construtor

EndClass   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³New       ³ Autor ³ Venda Clientes        ³ Data ³ 04.05.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Metodo contrutor da classe LJCSFIDados					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method New() Class LJCSFIDados
	
	::nContRedZ  	:= 0
	::nContOrdOp	:= 0
	::nContReinic	:= 0	
	::dDataMovto	:= CtoD("")
	::dDataRedZ		:= CtoD("")
	::cHoraRedZ		:= ""
	::nTotBrutDia	:= 0     
	::nTotCancDia	:= 0   	    
	::nTotOpNFis	:= 0
	::nTotCanIss	:= 0							
	::aImpsSFI		:= {}
	::cSerie		:= ""
 
Return

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CLASSE LJCSFIIMPS CONTEM OS DADOS RETORNADOS PELA BUSCA REFERENTE AOS IMPOSTOS.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJCSFIIMPS	 ºAutor  ³Vendas Clientes     º Data ³ 04.08.09 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Classe responsavel em retornar os dados da SFI                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja\FrontLoja                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/     
Class LJCFIImps

    Data cCodigo                       //Codigo do Imposto
    Data nValor                        //Valor da base do Imposto
    
    Method New()                       //Metodo Construtor
EndClass
        
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo	 ³New       ³ Autor ³ Venda Clientes        ³ Data ³ 04.05.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Metodo contrutor da classe LJCFIImps						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FrontLoja												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method New() Class LJCFIImps  

::cCodigo := ""
::nValor  := 0    

Return


