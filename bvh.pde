//--------------------------------------------------------- -*- Mode: Java -*-
// $Id: bvh/bvh.pde $
//
// Created 2009-09-09
//----------------------------------------------------------------------------

import processing.opengl.*;

color randomColor()
{
    return color((int)random(50,255),
                 (int)random(50,255),
                 (int)random(50,255), 200);
}

float square(float x) { return x * x; }

PVector min(PVector a, PVector b)
{
    return new PVector(min(a.x, b.x),
                       min(a.y, b.y),
                       min(a.z, b.z));
}

PVector max(PVector a, PVector b)
{
    return new PVector(max(a.x, b.x),
                       max(a.y, b.y),
                       max(a.z, b.z));
}

PVector lerp(PVector a, PVector b, float t)
{
    return new PVector(
        lerp(a.x, b.x, t),
        lerp(a.y, b.y, t),
        lerp(a.z, b.z, t));
}

//----------------------------------------------------------------------------
// Box
//----------------------------------------------------------------------------
class Box
{
    PVector min;
    PVector max;
    color c;

    Box()
    {
        clear();
        this.c = randomColor();
    }

    void clear()
    {
        float INF = 1.0 / 0.0;
        this.min = new PVector( INF, INF, INF);
        this.max = new PVector(-INF,-INF,-INF);
    }

    void addPoint(PVector p)
    {
        this.min = min(this.min, p);
        this.max = max(this.max, p);
    }

    void addBox(Box b)
    {
        this.min = min(this.min, b.min);
        this.max = max(this.max, b.max);
    }
    
    PVector center()
    {
        PVector r = PVector.add(this.min, this.max);
        r.mult(0.5);
        return r;
    }
    
    PVector size()
    {
        return PVector.sub(this.max, this.min);
    }

    float radius()
    {
        return size().mag() * 0.5;
    }

    void draw()
    {
        PVector sz = size();
        PVector p = center();
        fill(c);

        pushMatrix();
        translate(p.x, p.y, p.z);
        box(sz.x, sz.y, sz.z);
        popMatrix();
    }
};


//----------------------------------------------------------------------------
// BVH
//----------------------------------------------------------------------------
class BvhNode
{
    BvhNode above;
    BvhNode below;

    void draw()
    {
    }
   
};


//----------------------------------------------------------------------------
// Setup
//----------------------------------------------------------------------------

Box randomBox()
{
    Box box = new Box();
    box.addPoint(new PVector(random(-100, 100),
                             random(-100, 100),
                             random(-100, 100)));
    box.addPoint(new PVector(random(-100, 100),
                             random(-100, 100),
                             random(-100, 100)));
    box.addPoint(new PVector(random(-100, 100),
                             random(-100, 100),
                             random(-100, 100)));
    return box;
}

Box a = randomBox();
Box b = randomBox();

Box box = randomBox();
float heading = 0;
float pitch = radians(20);
float distance = 550;
PVector center = new PVector(0,0,0);

void setup()
{
    size(600, 600, P3D);

    box.clear();
    box.addBox(a);
    box.addBox(b);
}

void draw()
{
    resetMatrix();

    background(40);
    lights();

    distance = lerp(distance, box.radius() * 2.4, 0.1);
    center = lerp(center, box.center(), 0.1);

    beginCamera();
    resetMatrix();
    translate(center.x, center.y, center.z);
    rotateY(heading);
    rotateX(pitch);
    translate(0, 0, distance);
    endCamera();


    stroke(0,1,0);
    a.draw();
    stroke(1,0,1);
    b.draw();
    stroke(1,1,1);
    box.draw();
    
}

void mouseDragged()
{
    heading += (mouseX - pmouseX) * -0.01;
    pitch += (mouseY - pmouseY) * 0.01;
    pitch = constrain(pitch, -HALF_PI, HALF_PI);

    //redraw();
}

void keyTyped()
{
    if(key == 'r')
    {
    }
    else if(key == ']')
    {
    }
    else if(key == '[')
    {
    }
}
