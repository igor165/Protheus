#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RHIMP08.CH"

/**********************##**********************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....: RHIMP08.PRW Autor: Josias de Afelis  Data:09/03/2010 		 	***
***********************************************************************************
***Descrição..: Responsável pela importação de Funcionários.					***
***********************************************************************************
***Uso........:        															***
***********************************************************************************
***Parâmetros.: cFileName, caractere, Nome do Arquivo                     	    ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                               ***
***********************************************************************************
***					Alterações feitas desde a construção inicial       	 		***
***********************************************************************************
***Leandro Dr. |27/07/16|      |Tratamento para utilizacao de DE-PARA de rotina ***
***............|........|......|de importação genérica.                         ***
**********************************************************************************/

/*/{Protheus.doc} RHIMP08
Responsavel em Processar a Importacao dos funcionarios para a Tabela SRA.
@author Josias de Afelis
@since 09/03/2010
@version P11
@param cFileName, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@obs Defeito RHRH002-140
/*/
User Function RHIMP08(cFileName,aRelac,oSelf)
	Local aAreas		:= {SRA->(GetArea()),CCH->(GetArea()),RCE->(GetArea()),SPA->(GetArea())}
	Local cBuffer       := ""
	Local aLinha 		:= {}
	Local cEmpresaArq   := ""
	Local cFilialArq    := ""	
	Local cRAtpContr    := ""	
	Local aCampos       := {}
	Local aRotina       := {}
	Local aTabelas		:= {'SRA','CCH','SPA','RCE'}
	Local aIndSRA		:= {}
	Local nTamComplem	:=	TamSX3("RA_COMPLEM")[1]
	Local nTamMunicip	:=	TamSX3("RA_MUNICIP")[1]
	Local nTamBairro	:=	TamSX3("RA_BAIRRO")[1]
	Local nTamEmail		:=	TamSX3("RA_EMAIL")[1]
	Local nTamPai		:=	TamSX3("RA_PAI")[1]
	Local nTamMae		:=	TamSX3("RA_MAE")[1]
	Local nTamEnderec	:=	TamSX3("RA_ENDEREC")[1]
	Local xTemp			:=	0
	Local nTamCampos	:= 0
	Local nLinha		:= 0
	Local lUsasMin 		:= SuperGetMv("MV_USASMIN",,.F.)
	Local lItemClVl		:= SuperGetMv("MV_ITMCLVL", .F., "2" ) $ "13"
	Local lExiste		:= .F.
	Local cHelp 		:= ''
	Local nJ 			:= 0
	Local nX			:= 0
	Local nPos			:= 0
	Local nPosArq       := 0
	/*Quando vindo do RHIMPGEN os registros serão processados em threads.*/
	Local aRegistros		:= {}		
	Private aErro := {}
	Private oHash		:= Nil
	
	DEFAULT aRelac		:= {}

	if!(U_CanTrunk({'RA_COMPLEM','RA_MUNICIP','RA_BAIRRO','RA_EMAIL','RA_PAI','RA_MAE','RA_ENDEREC'}))
		Return (.T.)
	endIf
	
	//Inicia uma sessão para utilização das variáveis compartilhadas.
	VarSetUID("RHIMP08",.T.)	
	VarSetA("RHIMP08","aResumo",{})
	VarSetXD("RHIMP08","nLinhasOk",0)
	
	FT_FUSE(cFileName)	
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf,,2)	
	FT_FGOTOP()
	
	aRotina := GP010DEF()

	SRA->(dbSetOrder(1))
	CCH->(dbSetOrder(1))
	SPA->(dbSetOrder(1))
	RCE->(dbSetOrder(1))
	
	aAdd(aCampos,{'RA_FILIAL'})
	aAdd(aCampos,{'RA_MAT'})
	aAdd(aCampos,{'RA_CC'})
	aAdd(aCampos,{'RA_NOME'})
	aAdd(aCampos,{'RA_DEPTO'})
	aAdd(aCampos,{'RA_CODFUNC'})
	aAdd(aCampos,{'RA_ADMISSA'})
	aAdd(aCampos,{'RA_OPCAO'})
	aAdd(aCampos,{'RA_DEMISSA'})
	aAdd(aCampos,{'RA_BCDEPSA'})
	aAdd(aCampos,{'RA_CTDEPSA'})
	aAdd(aCampos,{'RA_BCDPFGT'})
	aAdd(aCampos,{'RA_CTDPFGT'})
	aAdd(aCampos,{'RA_HRSMES'})
	aAdd(aCampos,{'RA_HRSEMAN'})
	aAdd(aCampos,{'RA_TNOTRAB'})
	aAdd(aCampos,{'RA_PERCADT'})
	aAdd(aCampos,{'RA_CATFUNC'})
	aAdd(aCampos,{'RA_VIEMRAI'})
	aAdd(aCampos,{'RA_DEPIR'})
	aAdd(aCampos,{'RA_DEPSF'})
	aAdd(aCampos,{'RA_NOMECMP'})
	aAdd(aCampos,{'RA_SITFOLH'})
	aAdd(aCampos,{'RA_MSBLQL'})	
	aAdd(aCampos,{'RA_PGCTSIN'})
	aAdd(aCampos,{'RA_PERICUL'})
	aAdd(aCampos,{'RA_INSMIN'})
	aAdd(aCampos,{'RA_INSMED'})
	aAdd(aCampos,{'RA_INSMAX'})
	aAdd(aCampos,{'RA_TIPOADM'})
	aAdd(aCampos,{'RA_CATEG'})
	aAdd(aCampos,{'RA_TPCONTR'})
	aAdd(aCampos,{'RA_OCORREN'})
	aAdd(aCampos,{'RA_FICHA'})
	aAdd(aCampos,{'RA_RESCRAI'})
	aAdd(aCampos,{'RA_LOGRDSC'})
	aAdd(aCampos,{'RA_COMPLEM'})
	aAdd(aCampos,{'RA_CEP'})
	aAdd(aCampos,{'RA_MUNICIP'})
	aAdd(aCampos,{'RA_ESTADO'})
	aAdd(aCampos,{'RA_BAIRRO'})
	aAdd(aCampos,{'RA_TELEFON'})
	aAdd(aCampos,{'RA_NASC'})
	aAdd(aCampos,{'RA_NATURAL'})
	aAdd(aCampos,{'RA_NACIONA'})
	aAdd(aCampos,{'RA_CIC'})
	aAdd(aCampos,{'RA_PIS'})
	aAdd(aCampos,{'RA_TITULOE'})
	aAdd(aCampos,{'RA_ZONASEC'})
	aAdd(aCampos,{'RA_SECAO'})
	aAdd(aCampos,{'RA_RESERVI'})
	aAdd(aCampos,{'RA_RG'})
	aAdd(aCampos,{'RA_RGORG'})
	aAdd(aCampos,{'RA_RGEXP'})
	aAdd(aCampos,{'RA_ORGEMRG'})
	aAdd(aCampos,{'RA_RGUF'})	
	aAdd(aCampos,{'RA_SEXO'})
	aAdd(aCampos,{'RA_GRINRAI'})
	aAdd(aCampos,{'RA_ESTCIVI'})
	aAdd(aCampos,{'RA_SALARIO'})
	aAdd(aCampos,{'RA_DTCPEXP'})
	aAdd(aCampos,{'RA_DTRGEXP'})
	aAdd(aCampos,{'RA_HABILIT'})
	aAdd(aCampos,{'RA_NUMINSC'})
	aAdd(aCampos,{'RA_NUMCP'})
	aAdd(aCampos,{'RA_SERCP'})
	aAdd(aCampos,{'RA_UFCP'})
	aAdd(aCampos,{'RA_RACACOR'})
	aAdd(aCampos,{'RA_EMAIL'})
	aAdd(aCampos,{'RA_ANOCHEG'})
	aAdd(aCampos,{'RA_DEFIFIS'})
	aAdd(aCampos,{'RA_TPDEFFI'})
	aAdd(aCampos,{'RA_SINDICA'})
	aAdd(aCampos,{'RA_VCTOEXP'})
	aAdd(aCampos,{'RA_VCTEXP2'})	
	aAdd(aCampos,{'RA_PAI'})
	aAdd(aCampos,{'RA_MAE'})
	aAdd(aCampos,{'RA_FECREI'})
	aAdd(aCampos,{'RA_DTVTEST'})
	aAdd(aCampos,{'RA_CRACHA'})
	aAdd(aCampos,{'RA_NUMENDE'})
	aAdd(aCampos,{'RA_LOGRNUM'})
	aAdd(aCampos,{'RA_LOGRTP'})	
	aAdd(aCampos,{'RA_MATMIG'})
	aAdd(aCampos,{'RA_NACIONC'})
	aAdd(aCampos,{'RA_TPJORNA'})
	aAdd(aCampos,{'RA_CODMUN'})
	aAdd(aCampos,{'RA_CPAISOR'})
	aAdd(aCampos,{'RA_CODMUNN'})
	aAdd(aCampos,{'RA_DATCHEG'})
	aAdd(aCampos,{'RA_DATNATU'})
	aAdd(aCampos,{'RA_CASADBR'})
	aAdd(aCampos,{'RA_FILHOBR'})
	aAdd(aCampos,{'RA_PORTDEF'})
	aAdd(aCampos,{'RA_NUMCELU'})
	aAdd(aCampos,{'RA_EMAIL2'})
	aAdd(aCampos,{'RA_CATEFD'})
	aAdd(aCampos,{'RA_TPREINT'})
	aAdd(aCampos,{'RA_NRPROC'})
	aAdd(aCampos,{'RA_NRLEIAN'})
	aAdd(aCampos,{'RA_DTEFRET'})
	aAdd(aCampos,{'RA_DTEFRTN'})
	aAdd(aCampos,{'RA_EAPOSEN'})
	aAdd(aCampos,{'RA_DTVCCNH'})
	aAdd(aCampos,{'RA_DTEMCNH'})	
	aAdd(aCampos,{'RA_TIPOPGT'})
	aAdd(aCampos,{'RA_HOPARC'})
	aAdd(aCampos,{'RA_COMPSAB'})
	aAdd(aCampos,{'RA_ADTPOSE'})
	aAdd(aCampos,{'RA_ASSIST'})
	aAdd(aCampos,{'RA_CONFED'})
	aAdd(aCampos,{'RA_MENSIND'})
	aAdd(aCampos,{'RA_RESEXT'})
	aAdd(aCampos,{'RA_TPMAIL'})
	aAdd(aCampos,{'RA_HRSDIA'})
	aAdd(aCampos,{'RA_ADCPERI'})
	aAdd(aCampos,{'RA_ADCINS'})
	aAdd(aCampos,{'RA_PROCES'})
	aAdd(aCampos,{'RA_PRCFCH'})
	aAdd(aCampos,{'RA_PERFCH'})
	aAdd(aCampos,{'RA_ROTFCH'})
	aAdd(aCampos,{'RA_NUPFCH'})
	aAdd(aCampos,{'RA_DTCAGED'})
	
	aAdd(aCampos,{'RA_DTEMCNH'})
	aAdd(aCampos,{'RA_UFCNH'})
	aAdd(aCampos,{'RA_CATCNH'})
	aAdd(aCampos,{'RA_RNE'})
	aAdd(aCampos,{'RA_CLASEST'})
	aAdd(aCampos,{'RA_RNEORG'})
	aAdd(aCampos,{'RA_RNEDEXP'})
	aAdd(aCampos,{'RA_NUMRIC'})
	aAdd(aCampos,{'RA_EMISRIC'})
	aAdd(aCampos,{'RA_DEXPRIC'})
	aAdd(aCampos,{'RA_CODIGO'})
	aAdd(aCampos,{'RA_OCEMIS'})
	aAdd(aCampos,{'RA_OCDTEXP'})
	aAdd(aCampos,{'RA_OCDTVAL'})	
	aAdd(aCampos,{'RA_AUTMEI'})
	
	aEval(aCampos,{|x|aAdd(x,CriaVar(x[1],.T.,'L',.T.))})
	
	oHash := aToHM(aClone(aCampos))
	nTamCampos := Len(aCampos)
	
	aEval(aCampos,{|x|aAdd(x,Nil)})	
	
	CriaVar('RA_TIPOALT')
	CriaVar('RA_DATAALT')
	
	While !(FT_FEOF()) .And. !lStopOnErr
		cBuffer := FT_FREADLN()
		nLinha++
		If !(Empty(cBuffer))
			
			nPosArq := FT_FRecno()
			
			aLinha := {}
			aLinha := StrTokArr2(cBuffer,"|",.T.)
			
			if(!U_Proceed(118,Len(aLinha)))
				Return (.F.)
			Else
				aSize(aLinha,118)
			endIf			
						
			cEmpresaArq 	:= aLinha[1]
			cFilialArq		:= aLinha[2]
			
			If !Empty(aRelac) .and. u_RhImpFil()
				cEmpresaArq := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.T.) //Busca a Empresa no DE-PARA
				cFilialArq	:= u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.F.) //Busca a Filial no DE-PARA
			EndIf			
			
			U_RHPREARE(cEmpresaArq,cFilialArq,'','',.F.,@lExiste,"GPEA010",aTabelas,"GPE",@aErro,OemToAnsi(STR0001))
			
			IF lExiste			
				aCampos[1,2] := FwXFilial('SRA',cFilialArq)
				aCampos[2,2] := GetValue(aLinha[3]	, 'RA_MAT')
				aCampos[3,2] := GetValue(aLinha[4]	, 'RA_CC')
				aCampos[4,2] := aLinha[5]//RA_NOME				
				aCampos[5,2] := GetValue(aLinha[7]	, 'RA_DEPTO')				
				aCampos[6,2] := GetValue(aLinha[8]	, 'RA_CODFUNC')
				aCampos[7,2] := GetValue(aLinha[9]	, 'RA_ADMISSA'	,{|x|CToD(x)})
				aCampos[8,2] := GetValue(aLinha[10], 'RA_OPCAO'		,{|x|CToD(x)})
				aCampos[9,2] := GetValue(aLinha[11], 'RA_DEMISSA'	,{|x|CToD(x)})
				aCampos[10,2]:= GetValue(aLinha[12], 'RA_BCDEPSA')
				aCampos[11,2]:= GetValue(aLinha[13], 'RA_CTDEPSA')
				aCampos[12,2]:= GetValue(aLinha[14], 'RA_BCDPFGT')
				aCampos[13,2]:= GetValue(aLinha[15], 'RA_CTDPFGT')
				aCampos[14,2]:= GetValue(aLinha[16], 'RA_HRSMES'		,{|x|Val(AllTrim(x))})				
				aCampos[15,2]:= GetValue(aLinha[17], 'RA_HRSEMAN'	,{|x|Val(AllTrim(x))})			
				aCampos[16,2]:= GetValue(aLinha[18], 'RA_TNOTRAB')
				aCampos[17,2]:= GetValue(aLinha[19], 'RA_PERCADT'	,{|x|Val(AllTrim(x))})
				aCampos[18,2]:= GetValue(aLinha[20], 'RA_CATFUNC')
				/*Autonomos não são enviados na RAIS e não existe código (RA_VIEMRAI). 
				Como a informação será validada pelo GPEA010, iremos assumir um valor padrão válido,
				para que não ocorra inconsistências na importação.*/
				aCampos[19,2]:= If(aLinha[20] == "A" .and. Empty(aLinha[21]),"40",GetValue(aLinha[21], 'RA_VIEMRAI'))
				aCampos[20,2]:= GetValue(aLinha[22], 'RA_DEPIR')
				aCampos[21,2]:= GetValue(aLinha[23], 'RA_DEPSF')
				aCampos[22,2]:= GetValue(aLinha[24], 'RA_NOMECMP')
				aCampos[23,2]:= GetValue(aLinha[25], 'RA_SITFOLH')
				aCampos[24,2]:= IIF(aLinha[25] == "D"	,'1','2') //RA_MSBLQL 
				aCampos[25,2]:= GetValue(aLinha[26], 'RA_PGCTSIN')
				
				xTemp := IIF(Empty(aLinha[27]),0,Val(aLinha[27]))	
				If(xTemp >= 999 )					
					xTemp := aCampos[14,2]					
				EndIf				
				aCampos[26,2]:= xTemp //Periculosidade
				aCampos[27,2]:= GetValue(aLinha[28], 'RA_INSMIN'		,{|x|Val(x)})
				aCampos[28,2]:= GetValue(aLinha[29], 'RA_INSMED'		,{|x|Val(x)})								
				
				//Tratativa para Insalubridade Máxima
				xTemp := Val(aLinha[30])
				if(xTemp == 0)					
					if((aCampos[28,2] > 0) .And. (aCampos[28,2] < 999))
						xTemp := aCampos[28,2]	
					ElseIf ((aCampos[27,2] > 0) .And. (aCampos[27,2] < 999))
						xTemp := aCampos[27,2]	
					EndIf
				Else
					if(xTemp >= 999)
						xTemp := aCampos[14,2]					
					endIf
				endIf			
				aCampos[29,2]:= xTemp //RA_INSMAX				
				aCampos[30,2]:= GetValue(aLinha[31], 'RA_TIPOADM')
				aCampos[31,2]:= GetValue(aLinha[32], 'RA_CATEG'		,{|x|PadL(x,2,'0')})
				aCampos[32,2]:= GetValue(aLinha[33], 'RA_TPCONTR'	,{|x|IIF(AllTrim(x)=='I','1',(IIF(AllTrim(x)=='D','2',AllTrim(x))))})
				aCampos[33,2]:= GetValue(aLinha[34], 'RA_OCORREN'	,{|x|IIF(Len(x)== 1,'0'+ x,x)})
				aCampos[34,2]:= GetValue(aLinha[35], 'RA_FICHA')
				aCampos[35,2]:= GetValue(aLinha[36], 'RA_RESCRAI'	,{|x|IIF(AllTrim(x) == '0','',x)})	
				aCampos[36,2]:= GetValue(aLinha[37], 'RA_LOGRDSC')
				aCampos[37,2]:= SubStr(GetValue(aLinha[38], 'RA_COMPLEM'),1,nTamComplem)
				aCampos[38,2]:= GetValue(aLinha[39], 'RA_CEP')
				aCampos[39,2]:= SubStr(GetValue(aLinha[40], 'RA_MUNICIP'),1,nTamMunicip)
				aCampos[40,2]:= GetValue(aLinha[41], 'RA_ESTADO')				
				aCampos[41,2]:= SubStr(GetValue(aLinha[42], 'RA_BAIRRO'),1,nTamBairro)				
				aCampos[42,2]:= GetValue(aLinha[43], 'RA_TELEFON')
				aCampos[43,2]:= GetValue(aLinha[44], 'RA_NASC'	,{|x|CToD(x)})				 
				aCampos[44,2]:= GetValue(aLinha[45], 'RA_NATURAL')
				aCampos[45,2]:= GetValue(aLinha[46], 'RA_NACIONA')
				aCampos[46,2]:= GetValue(aLinha[47], 'RA_CIC')
				aCampos[47,2]:= GetValue(aLinha[48], 'RA_PIS')
				aCampos[48,2]:= GetValue(aLinha[49], 'RA_TITULOE')
				
				If !(Empty(aLinha[50]))
					m_zonasec := aLinha[50]
					m_zona  := "0" + substr(m_zonasec,1,3)
					m_secao := "0" + substr(m_zonasec,5,3)
				Else
					m_zona := ''
					m_secao:= '' 
				EndIf
				
				aCampos[49,2]:= GetValue(m_zona		, 'RA_ZONASEC')
				aCampos[50,2]:= GetValue(m_secao	, 'RA_SECAO')
				aCampos[51,2]:= GetValue(aLinha[51], 'RA_RESERVI')
				aCampos[52,2]:= GetValue(aLinha[52], 'RA_RG')				
				aCampos[53,2]:= GetValue(aLinha[53], 'RA_RGORG')
				aCampos[54,2]:= GetValue(aLinha[53], 'RA_RGEXP')
				aCampos[55,2]:= GetValue(aLinha[53], 'RA_ORGEMRG')				
				aCampos[56,2]:= GetValue(aLinha[54], 'RA_RGUF')
				aCampos[57,2]:= GetValue(aLinha[55], 'RA_SEXO')
				aCampos[58,2]:= GetValue(aLinha[56], 'RA_GRINRAI' 	,{|x| GetGrauIns(x)})			
				aCampos[59,2]:= GetValue(aLinha[57], 'RA_ESTCIVI')
				aCampos[60,2]:= GetValue(aLinha[58], 'RA_SALARIO'	,{|x|Val(AllTrim(x))})				
				aCampos[61,2]:= GetValue(aLinha[59], 'RA_DTCPEXP'	,{|x|CToD(x)})
				aCampos[62,2]:= GetValue(aLinha[60], 'RA_DTRGEXP'	,{|x|CToD(x)})
				aCampos[63,2]:= GetValue(aLinha[61], 'RA_HABILIT')
				aCampos[64,2]:= GetValue(aLinha[62], 'RA_NUMINSC')
				aCampos[65,2]:= GetValue(aLinha[63], 'RA_NUMCP')
				aCampos[66,2]:= GetValue(aLinha[64], 'RA_SERCP')
				aCampos[67,2]:= GetValue(aLinha[65], 'RA_UFCP')				
				aCampos[68,2]:= GetValue(aLinha[66], 'RA_RACACOR')
				aCampos[69,2]:= SubStr(GetValue(aLinha[67], 'RA_EMAIL'),1,nTamEmail)
				aCampos[70,2]:= GetValue(aLinha[68], 'RA_ANOCHEG')
				aCampos[71,2]:= GetValue(aLinha[69], 'RA_DEFIFIS')
				aCampos[72,2]:= GetValue(aLinha[70], 'RA_TPDEFFI')
				aCampos[73,2]:= GetValue(aLinha[71], 'RA_SINDICA')
				aCampos[74,2]:= GetValue(aLinha[72], 'RA_VCTOEXP'		,{|x|CToD(x)})
				aCampos[75,2]:= GetValue(aLinha[73], 'RA_VCTEXP2'		,{|x|CToD(x)})				
				aCampos[76,2]:= SubStr(GetValue(aLinha[74], 'RA_PAI'),1,nTamPai)
				aCampos[77,2]:= SubStr(GetValue(aLinha[75], 'RA_MAE'),1,nTamMae)
				aCampos[78,2]:= GetValue(aLinha[76], 'RA_FECREI'			,{|x|CToD(x)})
				aCampos[79,2]:= GetValue(aLinha[77], 'RA_DTVTEST'		,{|x|CToD(x)})
				aCampos[80,2]:= GetValue(aLinha[78], 'RA_CRACHA')
				aCampos[81,2]:= GetValue(aLinha[79], 'RA_LOGRNUM')
				aCampos[82,2]:= GetValue(aLinha[79], 'RA_NUMENDE')
				aCampos[83,2]:= GetValue(aLinha[80], 'RA_LOGRTP')
				aCampos[84,2]:= GetValue(aLinha[81], 'RA_MATMIG')	
				aCampos[85,2]:= GetValue(aLinha[82], 'RA_NACIONC'		,{|x|GetCountry(x)})
				aCampos[86,2]:= GetValue(aLinha[83], 'RA_TPJORNA')
				aCampos[87,2]:= GetValue(aLinha[84], 'RA_CODMUN'			,{|x|SubStr(x,3,5)})			
				aCampos[88,2]:= GetValue(aLinha[85], 'RA_CPAISOR'		,{|x|GetCountry(x)})
				aCampos[89,2]:= GetValue(aLinha[86], 'RA_CODMUNN'		,{|x|SubStr(x,3,5)})
				aCampos[90,2]:= GetValue(aLinha[87], 'RA_DATCHEG'		,{|x|CToD(x)})
				aCampos[91,2]:= GetValue(aLinha[88], 'RA_DATNATU'		,{|x|CToD(x)})	
				aCampos[92,2]:= GetValue(aLinha[89], 'RA_DATNATU'		,{|x|IIF(AllTrim(x)=='S','1','2')})
				aCampos[93,2]:= GetValue(aLinha[90], 'RA_FILHOBR'		,{|x|IIF(AllTrim(x)=='S','1','2')})				
				aCampos[94,2]:= GetValue(aLinha[91], 'RA_PORTDEF')
				aCampos[95,2]:= GetValue(aLinha[92], 'RA_NUMCELU')
				aCampos[96,2]:= GetValue(aLinha[93], 'RA_EMAIL2')
				aCampos[97,2]:= GetValue(aLinha[94], 'RA_CATEFD')
				aCampos[98,2]:= GetValue(aLinha[95], 'RA_TPREINT')
				aCampos[99,2]:= GetValue(aLinha[96], 'RA_NRPROC')
				aCampos[100,2]:= GetValue(aLinha[97], 'RA_NRLEIAN')
				aCampos[101,2]:= GetValue(aLinha[98], 'RA_DTEFRET'		,{|x|CToD(x)})
				aCampos[102,2]:= GetValue(aLinha[99], 'RA_DTEFRTN'		,{|x|CToD(x)})
				aCampos[103,2]:= GetValue(aLinha[100]	,'RA_EAPOSEN'		,{|x|IIF(AllTrim(x)=='S','1','2')})				
				aCampos[104,2]:= GetValue(aLinha[101]	,'RA_DTVCCNH'		,{|x|CToD(x)})
				aCampos[105,2]:= GetValue(aLinha[101]	,'RA_DTEMCNH'		,{|x|CToD(x)-1})
				/*Campos fixos devido a estrutura do LOGIX*/
				aCampos[106,2]:= 'M' //RA_TIPOPGT
				aCampos[107,2]:= '2' //RA_HOPARC
				aCampos[108,2]:= '2' //RA_COMPSAB
				aCampos[109,2]:= '***N**' //RA_ADTPOSE
				/*
					Posições {110,111,112,113 e 114), respectivamente
					RA_ASSIST, RA_CONFED, RA_MENSIND, RA_RESEXT e RA_TPMAIL
					ficam sempre com o valor do inicializador padrão,
					por isso não precisam sofrer alterações.				
				*/				
				aCampos[115,2]:= Round((aCampos[14,2]/30),4) // RA_HRSDIA
				
				/* Se (RA_PERICUL > 0) então (RA_ADCPERI := '2') caso contrário (RA_ADCPERI := '1') */			
				aCampos[116,2]:= IIF(aCampos[26,2] > 0,'2','1')				 
				
				if(aCampos[27,2] > 0) 	// Se (RA_INSMIN > 0)
					xTemp := '2'
				ElseIf(aCampos[28,2] > 0)// Se (RA_INSMED > 0)
					xTemp := '3'
				Elseif(aCampos[29,2] > 0)// Se (RA_INSMAX > 0)
					xTemp := '4'
				Else						// Caso contrário
					xTemp := '1'					
				endIf
				aCampos[117,2]:= xTemp //RA_ADCINS
				
				
				if(aCampos[18,2] $('AP')) //RA_CATFUNC
					if(aCampos[106,2] == 'M') // RA_TIPOPGT
						xTemp := '00003'
					Else
						xTemp := '00004'
					endIf
				ElseIf (aCampos[18,2] == 'S')//RA_CATFUNC
					xTemp := '00002'
				Else
					xTemp := '00001'
				EndIf
				
				aCampos[118,2] := xTemp //RA_PROCES
				
				aCampos[124,2] := GetValue(aLinha[102], 'RA_DTEMCHN',{|x|CToD(x)})
				/* Posição 103 não tem equivalência no Protheus:
					Campo Logix : rhu_funcionarios_compl.dat_prim_habl_cart_nacio_habl
				*/				
				aCampos[125,2] := GetValue(aLinha[104], 'RA_UFCNH')
				aCampos[126,2] := GetValue(aLinha[105], 'RA_CATCNH')
				aCampos[127,2] := GetValue(aLinha[106], 'RA_RNE')
				aCampos[128,2] := GetValue(aLinha[107], 'RA_CLASEST')
				aCampos[129,2] := GetValue(aLinha[108], 'RA_RNEORG')
				aCampos[130,2] := GetValue(aLinha[109], 'RA_RNEDEXP',{|x|CToD(x)})
				/* Posição 110 não tem equivalência no Protheus:
					Campo Logix : rhu_fun_rntgd.texto_parametro[1,1]
				*/				
				aCampos[131,2] := GetValue(aLinha[111], 'RA_NUMRIC')
				aCampos[132,2] := GetValue(aLinha[112], 'RA_EMISRIC')
				aCampos[133,2] := GetValue(aLinha[113], 'RA_DEXPRIC',{|x|CToD(x)})
				aCampos[134,2] := GetValue(aLinha[114], 'RA_CODIGO')
				aCampos[135,2] := GetValue(aLinha[115], 'RA_OCEMIS')
				aCampos[136,2] := GetValue(aLinha[116], 'RA_OCDTEXP',{|x|CToD(x)})
				aCampos[137,2] := GetValue(aLinha[117], 'RA_OCDTVAL',{|x|CToD(x)})
				/* Posição 118 não tem equivalência no Protheus:
					Campo Logix : rhu_dependente_compl.pensao_morte_auxilio_reclus
				*/				
				
				aCampos[138,2] := '2' //AUTMEI
				
				/* A partir desse trecho os campos são opcionais e podem existir ou não
					no vetor <aCampos>. A variável <nTamCampos> contém o tamanho do vetor
					sem os campos opcionais e é utilizada para se retornar o vetor a quantidade
					original depois de cada registro. 
				*/
				If lItemClVl										
					aAdd(aCampos,{'RA_ITEM',GetValue(aLinha[6],'RA_ITEM'),NIL})					
				Endif
				
				if(aCampos[32,2] == '2') /* Se (RA_TPCONTR == '2' */
					cRATpContr := AllTrim(aLinha[33])
					
					if(cRATpContr == 'D')				
						cRATpContr := '2'	
					ElseIf(cRATpContr == 'C')
						cRATpContr := '1'
					EndIf
					
					aAdd(aCampos,{'RA_CLAURES',cRATpContr,NIL})
					
					if!(Empty(aCampos[74,2])) /* Se (RA_VCTOEXP) diferente de vazio */
						if(aCampos[74,2] > aCampos[75,2])/* Se (RA_VCTOEXP > RA_VCTEXP2) */
							aAdd(aCampos,{'RA_DTFIMCT',aCampos[74,2],NIL})
						Else
							aAdd(aCampos,{'RA_DTFIMCT',aCampos[75,2],NIL})
						endIf
					endIf						
				endIf				
				
				if(!(Empty(aCampos[83,2])) .Or. !(Empty(aCampos[36,2])))					
					aAdd(aCampos,{'RA_ENDEREC',PadR((aCampos[83,2] + aCampos[36,2]),nTamEnderec),NIL})
				endIf				
				
				IF 	(SPA->(DbSeek(FwXFilial("SPA") + '01')))
					aAdd(aCampos,{'RA_REGRA'		,'01',Nil})
					aAdd(aCampos,{'RA_SEQTURN'	,'01',Nil})
				EndIf
				
				//Verifica existencia de DE-PARA
				If !Empty(aRelac)					
					If Empty(aIndSRA) //Grava a posicao dos campos que possuem DE-PARA
						For nX := 1 to Len(aCampos)
							For nJ := 1 to Len(aRelac)
								If (nPos := (aScan(aRelac[nJ],{|x| AllTrim(x) == AllTrim(aCampos[nX,1])}))) > 0
									aAdd(aIndSRA,{nX,aRelac[nJ,1]})
								EndIf 
							Next nJ
						Next nX
					EndIf
					For nX := 1 to Len(aIndSRA)
						aCampos[aIndSRA[nX,1],2] := u_GetCodDP(aRelac,aCampos[aIndSRA[nX,1],1],aCampos[aIndSRA[nX,1],2],aIndSRA[nX,2]) //Busca DE-PARA
					Next nX
				EndIf
				
				U_IncRuler(OemToAnsi(STR0001),aCampos[2,2],cStart,(!lExiste),,oSelf)				
				
				If Empty(aRelac)
					//Efetua a gravação via ExecAuto
					GravaFunc(aCampos,aRotina,@aErro,nLinha,cEmpresaArq,cFilialArq)
				Else
					aAdd(aRegistros,{aClone(aCampos),cEmpresaArq,cFilialArq,nLinha})
				EndIf
				
				/* Remove os campos opcionais para o vetor ser utilizado no próximo registro. */
				aSize(aCampos,nTamCampos)
			Else
				U_IncRuler(OemToAnsi(STR0001),aLinha[3],cStart,(!lExiste),,oSelf)
			EndIf
			
			If Empty(FT_FREADLN()) //Se ocorreu desposicionamento, reposiciona no arquivo
				FT_FUSE(cFileName)
				FT_FGoto(nPosArq)
			EndIf	
		EndIf
		/*Checa se deve parar o processamento.*/
		U_StopProc(aErro)			
		FT_FSKIP()		
	EndDo
	
	If !Empty(aRelac) .and. !Empty(aRegistros)
		fStartThread(@aErro,aRegistros,aRotina,oSelf)
	EndIf
	
	FT_FUSE()
	
	TrataResumo()
		
	U_RIM01ERR(aErro)	
	
	//Elimina as globais criadas
	VarClean("RHIMP08")
	
	/*Muda o parâmetro pra falso após a conversão dos funcionários.*/
	PutMV("MV_RHCONV", .F.)
	
	oHash:Clean()
	FreeObj(oHash)
	aSize(aCampos,0)
	aCampos := Nil
	aSize(aLinha,0)
	aLinha := Nil	
	aSize(aErro,0)
	aErro := Nil
	aEval(aAreas,{|x|RestArea(x)})
Return (.T.)

/*/{Protheus.doc} fStartThread
	Cria Threads para gravação
@author Leandro Drumond
@since 09/08/2016
@version P12
@return Nil
/*/
Static Function fStartThread(aErro,aRegistros,aRotina,oSelf)
Local aCampos	 := {}
Local aLogErro	 := {}
Local aThreadAux := {}
Local nQtdThread := Min(Ceiling( Len(aRegistros) / 25 ),4) //Quantidade máxima de threads => 4 (3 JOBS + Thread atual)
Local cEmpAux	 := ""
Local cFilAux	 := ""
Local nX		 := 0
Local nPos		 := 1
Local nRegsOk	 := 1
Local nRegsAux	 := 0
Local nRotFim	 := 0
Local nTamMax	 := 0
Local nTamAux	 := 0
Local nError	 := 0

aSort( aRegistros ,,, { |x,y| x[2]+x[3]+StrZero(x[4],10) < y[2]+y[3]+StrZero(y[4],10) } )

If nQtdThread > 1
	aThreadAux := {}
	aAdd(aThreadAux,{})
	nTamMax := Ceiling( Len(aRegistros) / nQtdThread )
EndIf

//oSelf:SetRegua2(Len(aRegistros))

For nX := 1 to Len(aRegistros)
	
	If nQtdThread == 1
		aCampos := aClone(aRegistros[nX,1])
		cEmpAux := aRegistros[nX,2]
		cFilAux := aRegistros[nX,3]
		GravaFunc(aCampos,aRotina,@aErro,nX,cEmpAux,cFilAux)
		U_IncRuler(OemToAnsi(STR0001),cValToChar(nX),cStart,.F.,,oSelf)
		U_StopProc(aErro)
		If lStopOnErr
			Exit
		EndIf
	Else
		nTamAux++
		If nTamAux > nTamMax
			nPos++
			nTamAux := 1
			aAdd(aThreadAux,{})
		EndIf
		aAdd(aThreadAux[nPos],{aClone(aRegistros[nX,1]),aRegistros[nX,2],aRegistros[nX,3],aRegistros[nX,4]})
	EndIf
Next nX

If Len(aThreadAux) > 0	
	VarSetXD("RHIMP08","nRotFim",0)
	VarSetXD("RHIMP08","nRegsOk",0)
	VarSetAD("RHIMP08","aLogErro",{})
	VarSetXD("RHIMP08","nError",0)	
	
	For nX := 1 to nQtdThread - 1 //O último array será processado na thread atual
		//³ Dispara thread ³
		StartJob("U_RhImp08Job",GetEnvServer(),.F.,cEmpAnt,cFilAnt,"000000",aThreadAux[nX],lErroNoFim,lStopOnErr,AllTrim(Str(nX)))
	Next nLoop
	
	aRegistros := aClone(aThreadAux[nQtdThread])
	
	For nX := 1 to Len(aRegistros)
		aCampos := aClone(aRegistros[nX,1])
		cEmpAux := aRegistros[nX,2]
		cFilAux := aRegistros[nX,3]
		GravaFunc(aCampos,aRotina,@aErro,aRegistros[nX,4],cEmpAux,cFilAux)		
		VarGetX("RHIMP08","nRegsOk",@nRegsAux)
		
		For nRegsOk := nRegsOk to nRegsAux
			//Incrementa contador de acordo com o número de registros processados
			U_IncRuler(OemToAnsi(STR0001),cValToChar(nX),cStart,.F.,,oSelf)
		Next nRegsOk
		
		U_StopProc(aErro)
				
		If lStopOnErr
			VarSetXD("RHIMP08","nError",1)
			Exit
		EndIf
		
		VarGetXD("RHIMP08","nError",@nError)

		If nError > 0
			Exit
		EndIf
	Next nX	
	
	//Processa enquanto as threads não forem finalizadas
	While .T.
		VarGetXD("RHIMP08","nRotFim",@nRotFim)
		VarGetX("RHIMP08","nRegsOk",@nRegsAux)
		
		For nRegsOk := nRegsOk to nRegsAux
			//Incrementa contador de acordo com o número de registros processados
			oSelf:IncRegua2("")
		Next nRegsOk
		
		If nRotFim == nQtdThread - 1
			Exit
		EndIf
	EndDo

	VarGetA("RHIMP08","aLogErro",@aLogErro)
	
	aEval(aLogErro, { |x| aAdd(aErro, x)  } )
EndIf

Return Nil

/*/{Protheus.doc} ErroForm
	Encapsula eventual error.log par não travar a thread
@author Leandro Drumond
@since 09/08/2016
@version P12
@return Nil
/*/
Static Function ErroForm(	oErr			,;	//01 -> Objeto oErr
							lNotErro		,;	//02 -> Se Ocorreu Erro ( Retorno Por Referencia )
							aLog			;
						)

Local aErrorStack
Local cMsgHelp	:= ""

DEFAULT lNotErro	:= .T.

If !( lNotErro := !( oErr:GenCode > 0 ) )
	cMsgHelp += "Error Description: "
	cMsgHelp += oErr:Description
	aAdd( aLog, cMsgHelp )
	aErrorStack	:= Str2Arr( oErr:ErrorStack , Chr( 10 ) )
	aEval( aErrorStack , { |X| aAdd(aLog, X) } )
EndIf

Break

Return( NIL )

/*/{Protheus.doc} RhImp08Job
	Inicializa ambiente das Threads
@author Leandro Drumond
@since 09/08/2016
@version P12
@return Nil
/*/
User Function RhImp08Job(xEmp, xFil, xUser,aRegs,lErroFim,lStopErr,cThread)
Local aLogError := {}
Local aLogAux	:= {}
Local aRotina   := {}
Local aErro		:= {}
Local lErroAux	:= .T.
Local bErro		:= Nil
Local nX		:= 0
Local nY		:= 0
Local nRegAux	:= 0
Local nRotFim	:= 0
Local nError	:= 0
Private lErroNoFim 		:= lErroFim
Private lStopOnErr 		:= lStopErr
Private aInconsistencia	:= {}
Private lAutoErrNoFile	:= .T.

//Prepara ambiente
RPCSetType( 3 )
RpcSetEnv( xEmp, xFil,,,"GPE") 
SetsDefault()

If Empty(cFilAnt)
	cFilAnt:= xFil
EndIf

__cUserId := xUser

bErro := ErrorBlock( { |oErr| ErroForm( oErr , @lErroAux, @aLogError ) } ) //Define um bloco de erro para eventual ocorrencia de error.log ser gravado no array aLogError.

aRotina   := GP010DEF()

Begin Sequence

	For nX := 1 to Len(aRegs)
		
		VarGetXD("RHIMP08","nError",@nError)

		If nError > 0
			Exit
		EndIf
		//Bloqueia edição da variavel global até atualização para manter integridade
		VarBeginT("RHIMP08","nRegsOk")
			VarGetXD("RHIMP08","nRegsOk",@nRegAux)
			nRegAux++
			VarSetXD("RHIMP08","nRegsOk",nRegAux)
		VarEndT("RHIMP08","nRegsOk")

		GravaFunc(aRegs[nX,1],aRotina,@aErro,aRegs[nX,4],aRegs[nX,2],aRegs[nX,3])

		U_StopProc(aErro)

		If lStopOnErr
			VarSetXD("RHIMP08","nError",1)
			Exit
		EndIf
	Next nX
End Sequence

ErrorBlock( bErro )

If !lErroAux //Se ocorreu error.log, para processamento.
	For nY := 1 to Len(aLogError)
		aAdd(aErro,aLogError[nY])
	Next nY
EndIf

If Len(aErro) > 0
	VarBeginT("RHIMP08","aLogErro")
		VarGetAD("RHIMP08","aLogErro",@aLogAux)
		For nX := 1 to Len(aErro)
			aAdd(aLogAux,aErro[nX])
		Next nX
		VarSetA("RHIMP08","aLogErro",aLogAux)
	VarEndT("RHIMP08","aLogErro")
EndIf

//Soma 1 no controle de threads finalizadas
VarBeginT("RHIMP08","nRotFim")
	VarGetXD("RHIMP08","nRotFim",@nRotFim)
	nRotFim++
	VarSetXD("RHIMP08","nRotFim",nRotFim)
VarEndT("RHIMP08","nRotFim")

Return Nil

/*/{Protheus.doc} GravaFunc
	Efetua ExecAuto do cadastro de funcionários
@author Leandro Drumond
@since 09/08/2016
@version P12
@return Nil
/*/
Static Function GravaFunc(aCampos,aRotina,aErro,nLinha,cEmpresaArq,cFilialArq)
Local aTemp			:= {}
Local aLog			:= {}
Local nOpc			:= 3
Local nPos			:= 0
Local nLinhasOk := 0	

Private lMsErroAuto	:= .F.

If cEmpresaArq <> cEmpAnt
	U_RHPREARE(cEmpresaArq,cFilialArq,'','',.F.,,"GPEA010",{'SRA','CCH','SPA','RCE'},"GPE",@aErro,OemToAnsi(STR0001))
EndIf

cFilAnt := cFilialArq

Begin Transaction
	SRA->(dbSetOrder(1))
		
	nOpc := IIF((SRA->(DbSeek(FwXFilial('SRA') + aCampos[2,2]))),4,3)
						
	If(nOpc == 4) /*Se for Edição*/		
		aTemp := aClone(aCampos)
		aDel(aTemp,1) //RA_FILIAL
		aSize(aTemp,Len(aTemp)-1)
		
		If(aCampos[60,2] != SRA->RA_SALARIO)
			aAdd(aTemp,{'RA_TIPOALT',"002",NIL})
			aAdd(aTemp,{'RA_DATAALT',Date(),NIL})
		else
			if((nPos := aScan(aTemp,{|x|x[1] == 'RA_SALARIO'}))> 0)
				aDel(aTemp,nPos)
				aSize(aTemp,Len(aTemp)-1)
			endIf
		EndIf	
		
		MSExecAuto({|x,y,w,z| GPEA010(x,y,w,z)},Nil,aRotina,aTemp,nOpc)
								
		aSize(aTemp,0)
	Else
		MSExecAuto({|x,y,w,z| GPEA010(x,y,w,z)},Nil,aRotina,aCampos,nOpc)
	EndIf					
	
	If lMsErroAuto
		DisarmTransaction()
		aLog := GetAutoGrLog()
				
		LimpaLog(aLog,@aErro,nLinha,cEmpresaArq,cFilialArq,aCampos[2,2])				
		aSize(aLog,0)
	else
		VarBeginT("RHIMP08","nLinhasOk")
		VarGetX("RHIMP08","nLinhasOk",@nLinhasOk)		
		nLinhasOk++
		VarSetXD("RHIMP08","nLinhasOk",nLinhasOk)
		VarEndT("RHIMP08","nLinhasOk")
	EndIf
	lMsErroAuto := .F.
	
End Transaction

Return Nil

/*/{Protheus.doc} GetValue
(long_description)
@author philipe.pompeu
@since 22/07/2015
@version P12
@param uValue, variável, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param bConv, bloco de código, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function GetValue(uValue,cField,bConv)	
	Local uResult	:= Nil
	Local cType	:= 'U'
	Default bConv := Nil
	
	if(Empty(uValue))		
		if!(HMGet(oHash,cField,@uResult))
			//TODO:Implementar alguma lógica pro caso de não encontrar
		Else
			uResult := uResult[1,2]
		endIf
	Else
		if(bConv == Nil)
			uResult :=  uValue
		Else
			uResult :=  eVal(bConv,uValue)
		endIf
	endIf
		
Return (uResult)

/*/{Protheus.doc} GetGrauIns
@author philipe.pompeu
@since 22/07/2015
@version P11
@param cGrauLogix, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function GetGrauIns(cGrauLogix)
	Local cGrauIns := cGrauLogix					
	If cGrauIns == "1"     	//Analfabeto
		cGrauIns := "10"
	ElseIf cGrauIns == "2"	//4a serie incompleta
		cGrauIns := "20"
	ElseIf cGrauIns == "3"	//4a serie completa
		cGrauIns := "25"
	ElseIf cGrauIns == "4"	//Primeiro grau incompleto
		cGrauIns := "30"
	ElseIf cGrauIns == "5"	//Primeiro grau completo
		cGrauIns := "35"
	ElseIf cGrauIns == "6"	//Segundo grau incompleto
		cGrauIns := "40"
	ElseIf cGrauIns == "7"	//Segundo grau completo
		cGrauIns := "45"
	ElseIf cGrauIns == "8"	//Superior incompleto
		cGrauIns := "50"
	ElseIf cGrauIns == "9" //.or. (cGrauCampo == "85")	//Superior completo ou Pos-Graduacao (Especializacao)
		cGrauIns := "55"
	ElseIf cGrauIns == "10"	//Mestrado
		cGrauIns := "65"
	ElseIf cGrauIns == "11" //.or. (cGrauCampo == "95")	//Doutorado ou Pos-Doutorado
		cGrauIns := "75"
	EndIf
Return (cGrauIns)

/*/{Protheus.doc} GetCountry
@author philipe.pompeu
@since 22/07/2015
@version P12
@param cCountry, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function GetCountry(cCountry)
	Local aArea	:= CCH->(GetArea())
	Local cNaciona:= AllTrim(cCountry)	

	If Len(cNaciona) > 2
		cNaciona:= "0"+cNaciona
	Else
		cNaciona:= "00"+cNaciona
	EndIf
	If cNaciona ==  "0001"
		cNaciona:= "01058"
	EndIf
	
	If 	(CCH->(DbSeek(xFilial("CCH") + cNaciona)))
		cNaciona:= CCH->CCH_CODIGO
	EndIf				
	
	RestArea(aArea)
	
Return (cNaciona)

Static Function LimpaLog(aLog,aErro,nLinha,cEmpresaArq,cFilialArq,cMat)
	Local nI := 0
	Local cTemp := ''
	Local nTotErr:=0
	Local nPos := 0
	Local cHelpCod := ''	
	Local aAuxResumo := {}
		
	/*Tratamento para resumir a mensagem de erro e tornar a leitura do log mais fácil.*/	
			
	VarBeginT("RHIMP08","aResumo")	
	VarGetA("RHIMP08","aResumo",@aAuxResumo)
					
	for nI:= 1 to Len(aLog)
		
		if(('HELP:' $ aLog[nI] .Or. '< --' $ aLog[nI]) .Or. ('AJUDA:' $ aLog[nI]))
			if(nTotErr == 0)
				cTemp := '[LINHA ' + AllTrim(Str(nLinha)) + ']['
				cTemp += 'EMPRESA :' + cEmpresaArq + ' '
				cTemp += 'FILIAL :' + cFilialArq + ' '
				cTemp += 'MATRÍCULA :' + cMat + ']' 					
				nTotErr++
				aAdd(aErro,cTemp)
			endIf				
			if('HELP:' $ aLog[nI]) .Or. ('AJUDA:' $ aLog[nI])
				cHelpCod := StrTran(aLog[nI],chr(13)+chr(10))  
				cHelpCod := AllTrim(SubStr(cHelpCod,At(':',cHelpCod)+ 1))
				cHelpCod := Left(cHelpCod,10) 
				
				nPos := aScan(aAuxResumo,{|x|x[1] == cHelpCod})
				if(nPos <= 0)
					aAdd(aAuxResumo,{cHelpCod,0})
					nPos := Len(aAuxResumo)
				endIf
				
				/*Incrementa a quantidade total de erros iguais.*/
				aAuxResumo[nPos,2]++						
			else
				cHelpCod := StrTran(aLog[nI],chr(13)+chr(10))  
				cHelpCod := SubStr(cHelpCod,At('-',cHelpCod)+ 1)
				cHelpCod := AllTrim(SubStr(cHelpCod,1,At(':',cHelpCod)-1)) 
				
				nPos := aScan(aAuxResumo,{|x|x[1] == cHelpCod})
				if(nPos <= 0)
					aAdd(aAuxResumo,{cHelpCod,0})
					nPos := Len(aAuxResumo)
				endIf
				
				/*Incrementa a quantidade total de erros iguais.*/
				aAuxResumo[nPos,2]++											
			endIf			
			aAdd(aErro, StrTran(aLog[nI],chr(13)+chr(10),'. '))
		endIf
	next nI	
	VarSetA("RHIMP08","aResumo",aClone(aAuxResumo))		
	VarEndT("RHIMP08","aResumo")
	
	aSize(aAuxResumo,0)
	aAuxResumo := Nil	
Return nil

Static Function TrataResumo()
	Local aResumo := {}
	Local nLinhasOk := 0
	Local xTemp	:=	0
	Local nX := 0
	Local nI := 0
	Local aHelp := {}
	
	VarGetAD("RHIMP08","aResumo",@aResumo)
	VarGetX("RHIMP08","nLinhasOk",@nLinhasOk)	
	for nX := 1 to Len(aResumo)
		if(nX == 1)			
			U_RIM01ERR(PadC(' RESUMO DO PROCESSAMENTO ',128,'#'))
			
			if(nLinhasOk > 0)				
				xTemp := 'Foram processadas corretamente ' + cValToChar(nLinhasOk)
				
				if(nQtdLinhas > 0)
					xTemp += '( ' + cValToChar(Round((nLinhasOk/nQtdLinhas)*100,2)) +' % )'						
				endIf
				
				xTemp += ' linhas.'				
				U_RIM01ERR(xTemp)
			endIf
			xTemp := PadC('CÓDIGO DO ERRO',20) + '|'
			xTemp += PadC('QTD. OCORRÊNCIAS',20) + '|'
			xTemp += PadC('PROBLEMA',44) + '|'
			xTemp += PadC('SOLUÇÃO',44) + '|'			
			
			U_RIM01ERR(Replicate('-',Len(xTemp)))
			U_RIM01ERR(xTemp)
			U_RIM01ERR(Replicate('-',Len(xTemp)))	
		endIf
		
		xTemp := PadC(aResumo[nX,1],20) + '|'
		xTemp += PadC(cValToChar(aResumo[nX,2]),20) + '|'
		
		if('RA_' $ aResumo[nX,1])			
			xTemp += PadC('CAMPO ' + aResumo[nX,1] + ' INVÁLIDO.',44) + '|'
			xTemp += PadC('VERIFICAR OS VALORES INFORMADOS.',44) + '|'
		else
			aHelp := GetHlpSoluc(aResumo[nX,1])		
			if!(Len(aHelp) > 1)		
				if(Empty(aHelp[1]))				
					aHelp[1] := 'DESCRIÇÃO NÃO ENCONTRADA.'
				endIf
				if(Empty(aHelp[2]))
					aHelp[2] := 'CONFERIR O HELP DO PRODUTO.' 
				endIf
			else
				aHelp := {'DESCRIÇÃO NÃO ENCONTRADA.','CONFERIR O HELP DO PRODUTO.'}				
			endIf
			
			xTemp += PadC(aHelp[1],44) + '|'
			xTemp += PadC(aHelp[2],44) + '|'
		endIf		
		U_RIM01ERR(xTemp)
		
		xTemp := Replicate('-',20) + '|'
		xTemp += Replicate('-',20) + '|'
		xTemp += Replicate('-',44) + '|'
		xTemp += Replicate('-',44) + '|'
		U_RIM01ERR(xTemp)
		if(nX == Len(aResumo))
			U_RIM01ERR(PadC(' FIM DO RESUMO ',128,'*'))			
		endIf		
	next nI	
	
Return nil

/*/{Protheus.doc} GP010DEF
Monta aRotina para uso no execauto do cadastro de funcionários
@author Leandro.Drumond
@since 08/03/2022
@version P112
@return aRotina
/*/
Static Function GP010DEF()

Local aRotina := {}

AAdd(aRotina, {"Pesquisar"	, "PesqBrw",    0, 1, NIL, .F.})// "Pesquisar"
AAdd(aRotina, {"Visualizar"	, "Gpea010Vis", 0, 2, 192})	 	// "Visualizar"
AAdd(aRotina, {"Incluir"	, "Gpea010Inc", 0, 3, 81})	 	// "Incluir"
AAdd(aRotina, {"Alterar"	, "Gpea010Alt", 0, 4, 82})	 	// "Alterar"

Return ( aRotina )
