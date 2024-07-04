#INCLUDE "Reproweb.ch"
#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReproweb  บAutor  ณRodrigo Zatt        บ Data ณ 26/05/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLe o arquivo de retorno da Reproweb - AFIP                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFis                                                     บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณData    ณ BOPS     ณ Motivo da Alteracao                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณJonathan Glzณ04/01/17ณSERINN001-ณSe modifica uso de tablas temporales  ณฑฑ
ฑฑณ            ณ        ณ       893ณpor motivo de limpieza de CTREE.      ณฑฑ
ฑฑณAlf Medrano ณ20/02/17ณMMI-116ณEn la func. Reprowebtmp() se asigna el   ณฑฑ
ฑฑณ            ณ        ณ       ณIdentificador de Pag. CBU Informada. En  ณฑฑ
ฑฑณ            ณ        ณ       ณfunc ReprowebLe se asigna el Valor del   ณฑฑ
ฑฑณ            ณ        ณ       ณIdent. Pag. CBU a la archivo temporal    ณฑฑ
ฑฑณ            ณ        ณ       ณEn Func ReprowebAtu se valida el llenado ณฑฑ
ฑฑณ            ณ        ณ       ณde las Fechas Inicio y Fin CBU cuando    ณฑฑ
ฑฑณ            ณ        ณ       ณIdent. Pag. CBU = ‘10’ pais ARG          ณฑฑ
ฑฑณAlf Medrano ณ28/02/17ณ       ณMerge Main vs 12.1.14                    ณฑฑ
ฑฑณM.Camargo   ณ06/05/20ณ       ณ12.1.25/12.1.27 incoporaci๓n rpo         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/      
Function Reproweb()                     

Local aArqTmp	:= {}
Local aCarga	:= {}
Local cTitulo	:= ""
Local cErro		:= ""
Local cSolucao	:= ""
Local lCarga 	:= .F.

Private oTmpTable
Private aOrder    := {}

If ReproweWiz()	   
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCarrega no arquivo temporario as informacoes do arquivo de retornoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Processa({|| aCarga := ReprowebLe(@aArqTmp)})
		lCarga := aCarga[01]   
		If lCarga
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza tabelas com as informacoes do retornoณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Processa({|| ReprowebAtu(aCarga[02])})
			 
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณImprime o relatorio de conferencia no release 3 e 4 ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		 	If FindFunction("TRepInUse") .And. TRepInUse()
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณInterface de impressao                                                  ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				oReport := ReportDef()
				oReport:PrintDialog()
			Else
		 	 	RprowebR3()
	 	EndIf
		Else
			cTitulo 	:= STR0024		//"Importa็ใo nใo realizada"	
			cErro		:= STR0025		//"A importa็ใo do arquivo de retorno nใo foi realizada "
			cErro		+= STR0026		//"por nใo existirem informa็๕es de retorno no arquivo "
			cErro		+= STR0027		//"texto informado. "
			cSolucao	:= STR0028		//"Verifique se o arquivo de retorno informado nas "
			cSolucao	+= STR0029		//"perguntas da rotina ้ o enviado pela Reproweb "
			cSolucao	+= STR0030		//"e processe esta rotina novamente."
			xMagHelpFis(cTitulo,cErro,cSolucao)
		Endif
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณExcluindo o arquivo temporario criadoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea(aArqTmp[1])
		dbCloseArea()

		If oTmpTable <> Nil   //JGR
			oTmpTable:Delete()  //JGR
			oTmpTable := Nil //JGR
		Endif //JGR

Else
	cTitulo 	:= STR0018 				//"Implementa็ใo nใo efetuada"	
	cErro		:= STR0019 				//"A implementa็ใo do processo de atualiza็ใo"
	cErro		+= STR0020 				//"Reproweb nใo foi efetuada corretamente."
	cSolucao	:= STR0021 				//"verifique a documenta็ใo que acompanha a rotina e "
	cSolucao	+= STR0022 				//"execute todos os procedimentos indicados e processe "
	cSolucao	+= STR0023 				//"esta rotina novamente."
	xMagHelpFis(cTitulo,cErro,cSolucao)
Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReproweWiz  บAutor  ณRodrigo Zatt        บ Data ณ 26/05/2008  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta a wizard com as perguntas a rotina de importacao        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณReproweb                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReproweWiz()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDeclaracao das variaveisณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aTxtPre 		:= {}
Local aPaineis 		:= {}

Local cTitObj1		:= ""                
Local cMask			:= Replicate("X",245)
	
Local nPos			:= 0
	
Local lRet			:= 0
Local cCab			:= STR0001 //"Importa็ใo do Arquivo Reproweb"
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta wizard com as perguntas necessariasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aTxtPre,STR0001) //"Importa็ใo do Arquivo Reproweb"
aAdd(aTxtPre,STR0002) //"Aten็ใo"
aAdd(aTxtPre,STR0003) //"Preencha corretamente as informa็๕es solicitadas."
aAdd(aTxtPre,Alltrim(STR0004)+" "+cCab+Alltrim(STR0005)+" "+Alltrim(STR0006))	
										//"Esta rotina ira importar o arquivo de retorno disponibilizado pela Reproweb       "
										//", contendo informa็๕es sobre fornecedores     "
										//"em um deternimado perํodo."

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPainel 1 - Informacoes da Empresa    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aPaineis,{})
nPos :=	Len(aPaineis)
aAdd(aPaineis[nPos],STR0007) //"Assistente de parametriza็ใo" 
aAdd(aPaineis[nPos],STR0008) //"Informa็๕es sobre o arquivo de retorno: "
aAdd(aPaineis[nPos],{})

cTitObj1 :=	STR0009 //"Arquivo de retorno: "
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
aAdd(aPaineis[nPos][3],{2,"",cMask,1,,,,245,,.T.})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})

lRet :=	xMagWizard(aTxtPre,aPaineis,"Rproweb")
	
Return(lRet)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReprowebTmp บAutor  ณRodrigo Zatt        บ Data ณ 26/05/2008  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria o arquivo temporario para importacao                     บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณReproweb                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function reprowebTmp()

Local aArqPRO   := {}                                 
Local aArqTmp	:= {}

AADD(aArqPRO,{"CGC"		    ,"C",11,0})
AADD(aArqPRO,{"CGCFOR"      ,"C",11,0})
AADD(aArqPRO,{"DATAI"	    ,"C",07,0})
AADD(aArqPRO,{"CODRE"   	,"C",21,0})
AADD(aArqPRO,{"SITUA"   	,"C",01,0})
AADD(aArqPRO,{"DATAF"		,"C",10,0})
AADD(aArqPRO,{"IMPORT"		,"C",01,0}) 
AADD(aArqPRO,{"ERRO"		,"C",35,0})
AADD(aArqPRO,{"IDEPA"	,"C",5,0})
//Creacion de Objeto
aOrder	:=	{"CGCFOR"} //JGR
oTmpTable := FWTemporaryTable():New("PRO") //JGR
oTmpTable:SetFields( aArqPRO ) //JGR
oTmpTable:AddIndex("I01", aOrder) //JGR
oTmpTable:Create() //JGR

aArqTmp := {"PRO"}

Return(aArqTmp)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReprowebLe  บAutor  ณRodrigo Zatt        บ Data ณ 26/05/2008  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLe arquivo de retorno Reproweb e carrega o arquivo temporario บฑฑ
ฑฑบ          ณpara atualizar cadastro de Fornecedor.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณReproweb                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReprowebLe(aArqTmp)

Local aWizard		:= {}
Local aInforma      := {}
Local lRet			:= !xMagLeWiz("Rproweb",@aWizard,.T.)
Local cArqProc		:= Alltrim(aWizard[01][01])
Local cTitulo		:= ""
Local cErro			:= ""
Local cSolucao		:= ""
Local cLinha		:= ""
Local cChar			:= ""
Local lCarga		:= .F.   
Local lArqValido	:= .F.
Local nCont			:= 0
Local nX            := 0 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria o arquivo temporario para a importacaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aArqTmp := ReprowebTMP()                                  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se o arquivo existe no diretorio indicadoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If File(cArqProc) .And. !lRet

	nHandle	:=	FOpen(cArqProc)
	nTam	:=	FSeek(nHandle,0,2)
	FSeek(nHandle,0,0)
	ProcRegua(nTam)

	FT_FUse(cArqProc)
	FT_FGotop()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se o arquivo aberto e um arquivo valido com o mesmo CGC do SM0ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	lArqValido 	:= .F.	
	cChar  		:= "."       
	nCont	    := 0
	
	cLinha := ""
  	cLinha := FT_FREADLN()	
	If (Alltrim(SubStr(cLinha,1,11)) == Alltrim(SM0->M0_CGC))
		lArqValido := .T.				
	Endif
	
	If lArqValido 
		FT_FGotop()
		FSeek(nHandle,0,0)
		cChar  := ","		
		cLinha := ""		
		
		While (!FT_FEof()) 		
			IncProc()
			cLinha := ""        
			aDadosSA := {}
		    aInforma := {}	            
   			cLinha := FT_FREADLN()
        	RecLock("PRO",.T.)
        			For nX := 1 to 7
        	        	nPos := at(",",cLinha)
        	        	IF (nPos == 0 .AND. nX == 7)
        	        		AADD (aInforma,AllTrim(cLinha))
        	        	Else
        	        	AADD (aInforma,Alltrim(SubStr(cLinha,1,(nPos-1))))
        	        	cLinha := SubStr(cLinha,nPos+1,Len(cLinha))
        	        	ENDIF
        	        nEXT
        	  		PRO->CGC		:= aInforma [1]
					PRO->CGCFOR  	:= aInforma [2]
					PRO->DATAI		:= aInforma [3]
					PRO->CODRE  	:= SubStr(aInforma [4],2,22)
					PRO->SITUA		:= aInforma [5]
					PRO->DATAF		:= aInforma [6]
					PRO->IDEPA		:= aInforma [7]
			FT_FSkip()
		Enddo 
		lCarga := .T.        
	Else
		lCarga := .F.
	Endif	
	FT_FUse()
	FClose(nHandle)
Else 
	cTitulo 	:= STR0011 						//"Arquivo de importa็ใo nใo localizado"	
	cErro		:= STR0012 + cArqProc			//"Nใo foi localizado no diret๓rio "
	cErro		+= STR0013 + STR0014 	        //" o arquivo "," indicado nas perguntas "
	cErro		+= STR0015 						//"da rotina."
	cSolucao	:= STR0016 						//"Informe o diret๓rio e o nome do arquivo "
	cSolucao	+= STR0017 						//"corretamente e processe a rotina novamente."
	xMagHelpFis(cTitulo,cErro,cSolucao)
	lCarga := .F.
Endif

Return({lCarga,cArqProc})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReprowebAtu บAutor  ณRodrigo Zatt        บ Data ณ 26/05/2008  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza tabela do Protheus com as informacoes retornadas     บฑฑ
ฑฑบ          ณpela Reproweb tabela de Fornecedores                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณReproweb                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                                                                    
Static Function ReprowebAtu(cCarga)

ProcRegua(PRO->(LastRec()))
SA2->(dbSetOrder(3))

PRO->(dbGoTop())
While !(PRO->(Eof()))

	IncProc()
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtualizando tabelas posicionadasณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If SA2->(MsSeek(xFilial("SA2")+Alltrim(PRO->CGCFOR)))
		While !SA2->(EOF()) .And. xFilial("SA2") == SA2->A2_FILIAL .And. Alltrim(PRO->CGCFOR) == Alltrim(SA2->A2_CGC)
		  	Begin Transaction
				RecLock("SA2",.F.)
				SA2->A2_REPRO	:= PRO->CODRE
				SA2->A2_SITU	:= PRO->SITUA
				IF (Alltrim(PRO->IDEPA) == "10")
					IF EMPTY(SA2->A2_CBUINI)
						SA2->A2_CBUINI := CTOD("01/"+ substr(PRO->DATAI,1,2) +"/"+ substr(PRO->DATAI,3))
					EndIf					
					SA2->A2_CBUFIM := CTOD(CVALTOCHAR (Last_Day ("01/" + substr(PRO->DATAI,1,2) + "/" + substr(PRO->DATAI,3)))+ "/" + substr(PRO->DATAI,1,2) + "/" + substr(PRO->DATAI,3))
				EndIf
				MsUnLock()
			End Transaction
			SA2->(dbSkip())
		EndDo
		
 		RecLock("PRO",.F.)
 		PRO->ERRO :=STR0041 //"Importado"
		MsUnLock()
 	Else
    	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSe houve algum erro na atualizacao das tabelasณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		RecLock("PRO",.F.)
		PRO->IMPORT	:= "1"
		PRO->ERRO	:= STR0031 //"Fornecedor nใo encontrado"
		MsUnLock() 	
	EndIf
	PRO->(dbSkip())
Enddo

Return(.T.)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportDef   บAutor  ณRodrigo Zatt        บ Data ณ 26/05/2008  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime um relatorio de conferencia com os dados importados e บฑฑ
ฑฑบ          ณos que nao foram importados por erro - Release 4              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณReproweb                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                                                                    
Static Function ReportDef()

Local aOrdem 	:= {}
Local oReport
Local oImport
Local oTotal                                

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณComponente de impressaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oReport := TReport():New("Reproweb",STR0037,"Rproweb",{|oReport| ReportPrint(oReport)},STR0047) // "Impressใo da listagem de confer๊ncia Reproweb. ","Este programa irแ apresentar uma listagem com o resultado da importa็ใo do retorno do Reproweb"
oReport:HideParamPage()
oReport:SetLandscape()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSecao 1 Impressao da Listagem ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oImport := TRSection():New(oReport,STR0037,{"PRO"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/) // "Impressใo da listagem de confer๊ncia Reproweb"
oImport:SetHeaderSection(.T.) 
oImport:SetReadOnly()
TRCell():New(oImport,"CGCFOR"	,"PRO",STR0032 /*"CGC fornecedor"*/,/*Picture*/,11,/*lPixel*/,/*{|| codblock de impressao }*/)
TRCell():New(oImport,"DATAI"	,"PRO",STR0033 /*"Periodo solicitado"*/,/*Picture*/,8,/*lPixel*/,/*{|| codblock de impressao }*/)
TRCell():New(oImport,"CODRE"	,"PRO",STR0034 /*"cod. Reproweb"*/,/*Picture*/,21,/*lPixel*/,/*{|| codblock de impressao }*/)
TRCell():New(oImport,"SITUA"	,"PRO",STR0035 /*"Situacao"*/,/*Picture*/,1,/*lPixel*/,/*{|| codblock de impressao }*/)
TRCell():New(oImport,"DATAF"	,"PRO",STR0036 /*"Data fechamento"*/,/*Picture*/,8,/*lPixel*/,/*{|| codblock de impressao }*/)
TRCell():New(oImport,"ERRO"  	,"PRO",STR0035 /*"Situa็ใo"*/,/*Picture*/,35,/*lPixel*/,/*{|| codblock de impressao }*/)

oTotal := TRFunction():New(oImport:Cell("CGCFOR"),Nil,"COUNT",/*oBreak2*/,STR0044,"9999999999",/*uFormula*/,.F.,.T.) // "Total de documentos importados sem erro: "
oTotal:SetCondition({ || PRO->IMPORT <> "1" })
oTotal := TRFunction():New(oImport:Cell("CGCFOR"),Nil,"COUNT",/*oBreak2*/,STR0045,"9999999999",/*uFormula*/,.F.,.T.) // "Total de documentos nใo importados:      "
oTotal:SetCondition({ || PRO->IMPORT == "1" })

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportPrint บAutor  ณRodrigo Zatt        บ Data ณ 26/05/2008  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressao do detalhe do relatorio de conferencia no Release 4 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณReproweb                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                                                                    
Static Function ReportPrint(oReport)                     

Local cChave := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRegua de Processamento                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oReport:SetMeter(PRO->(LastRec()))
oReport:Section(1):Init()      

PRO->(dbGoTop())

Do While !PRO->(Eof())
	If cChave == PRO->CGCFOR
		oReport:Section(1):Cell("CGCFOR"):Hide()
		oReport:Section(1):Cell("DATAI"):Hide()
		oReport:Section(1):Cell("CODRE"):Hide()
		oReport:Section(1):Cell("SITUA"):Hide()  
		oReport:Section(1):Cell("DATAF"):Hide()
		oReport:Section(1):Cell("ERRO"):Hide()
	Else
		oReport:Section(1):Cell("CGCFOR"):Show()
		oReport:Section(1):Cell("DATAI"):Show()
		oReport:Section(1):Cell("CODRE"):Show()
		oReport:Section(1):Cell("SITUA"):Show()
		oReport:Section(1):Cell("DATAF"):Show()
        oReport:Section(1):Cell("ERRO"):Show() 		
	Endif
    cChave:= PRO->CGCFOR
	oReport:Section(1):PrintLine() 	
	oReport:IncMeter()
	
	PRO->(dbSkip())

Enddo

oReport:Section(1):Finish()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRprowebR3   บAutor  ณRodrigo Zatt        บ Data ณ 26/05/2008  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime um relatorio de conferencia com os dados importados e บฑฑ
ฑฑบ          ณos que nao foram importados por erro - Release 3              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณReproweb                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                                                                    
Static Function RprowebR3()

Local Titulo      	:= OemToAnsi(STR0037)	//"Impressใo da listagem de confer๊ncia Reproweb"
Local cDesc1      	:= OemToAnsi(STR0038)	//"Este programa ira emitir uma listagem de confer๊ncia com o resultado "
Local cDesc2      	:= OemToAnsi(STR0039)	//"da importa็ใo do Reproweb, apresentando os documentos "
Local cDesc3      	:= OemToAnsi(STR0040)	//"importados e nใo importados."
Local lDic        	:= .F. 					// Habilita/Desabilita Dicionario
Local lComp       	:= .F. 					// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro     	:= .F. 					// Habilita/Desabilita o Filtro
Local wnrel       	:= "Reproweb"  			// Nome do Arquivo utiLizado no Spool
Local nomeprog    	:= "Reproweb"  			// nome do programa
Local nPagina     	:= 0

Private Tamanho 	:= "G" 					// P/M/G
Private Limite  	:= 220 					// 80/132/220
Private aOrdem  	:= {}  					// Ordem do Relatorio
Private aReturn 	:= { STR0042, 1,STR0043, 1, 2, 1, "",1 }  //"Zebrado"###"Administracao"
Private lEnd    	:= .F.					// Controle de cancelamento do relatorio
Private m_pag   	:= 1  					// Contador de Paginas
Private nLastKey	:= 0  					// Controla o cancelamento da SetPrint e SetDefault

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEnvia para a SetPrint                                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := SetPrint("",NomeProg,"",@Titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,Tamanho,,.F.)
If ( nLastKey==27 )
	dbSetOrder(1)
	dbClearFilter()
	Return
Endif
SetDefault(aReturn)
If ( nLastKey==27 )
	dbSetOrder(1)
	dbClearFilter()
	Return
Endif

RptStatus({|lEnd| nPagina := RprowebDet(@lEnd,wnRel,nomeprog,Titulo)},Titulo)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Restaura Ambiente                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbClearFilter()
Set Device To Screen
Set Printer To
		
If ( aReturn[5] = 1 )
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRprowebR3   บAutor  ณRodrigo Zatt        บ Data ณ 26/05/2008  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressao do detalhe do relatorio de conferencia no Release 3 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณReproweb                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                                                                    
Static Function RprowebDet(lEnd,wnRel,nomeprog,Titulo)

Local cCabec1	:= STR0046 //"CGC Fornecedor    Periodo Solicitado Cod. Eletronico Reproweb  situa็ใo Data fechamento    Mensagem de Erro"
Local cCabec2	:= ""
Local cChave	:= ""
Local nLin		:= 60
Local nImport	:= 0
Local nErro		:= 0

PRO->(dbGoTop())
dbSelectArea("PRO")
SetRegua(LastRec()) 

While !lEnd .And. !PRO->(Eof())

	If nLin > 55
		nLin := Cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,18)
	Endif
	
	nLin++
	
	If cChave <> PRO->CGC+PRO->CGCFOR
		@nLin, 000 PSay PRO->CGCFOR
		@nLin, 019 PSay PRO->DATAI
		@nLin, 042 PSay PRO->CODRE
		@nLin, 071 PSay PRO->SITUA
		@nLin, 084 PSay PRO->DATAF
		cChave := PRO->CGC+PRO->CGCFOR

		If PRO->IMPORT <> "1"
			@nLin, 104 PSay STR0041 //"Importado"
			nImport += 1
		Else
			@nLin, 104 PSay STR0031 //"Fornecedor nใo encontrado"
			nErro += 1
		Endif
	Else
	Endif
	PRO->(dbSkip())
Enddo             

If nImport + nErro > 0

	nLin++
	@nLin,000 Psay Repli("-",Limite)                        
    nLin++
    
	If nLin > 55
		nLin := Cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,15)
		nLin++
	Endif    
	
	@nLin, 000 PSay STR0044 + Str(nImport,10) // "Total de documentos importados sem erro: "
	nLin++
	@nLin, 000 PSay STR0045 + Str(nErro,10) // "Total de documentos nใo importados:      "
	
Endif

Return(.T.)
