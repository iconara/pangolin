package com.example;


import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertEquals;


public class TestHelloWorld {

	private HelloWorld helloWorld;
	

	@Before
	public void setUp( ) {
		helloWorld = new HelloWorld();
	}
	
	@Test
	public void testTheObvious( ) {
		assertNotNull(helloWorld);
	}
	
	@Test
	public void testThatFails( ) {
		assertEquals(1, 2);
	}

}