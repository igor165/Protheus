#INCLUDE 'PROTHEUS.CH'

User Function MT103SE2()
	Local aRet:= {}// Customizações desejadas para adição do campo no grid de informações

	aAdd(aRet,{;
				AllTrim(GetSx3Cache("E2_CODBAR","X3_TITULO")),;
				"E2_CODBAR",;
				AllTrim(GetSx3Cache("E2_CODBAR","X3_PICTURE")),;
				GetSx3Cache("E2_CODBAR","X3_TAMANHO"),;
				GetSx3Cache("E2_CODBAR","X3_DECIMAL"),;
				GetSx3Cache("E2_CODBAR","X3_VALID"),;
				GetSx3Cache("E2_CODBAR","X3_USADO"),;
				GetSx3Cache("E2_CODBAR","X3_TIPO"),;
				"",;
				"",;
				"",;
				"",;
				".T.";
				})
Return aRet

